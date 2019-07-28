'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const stripe = require('stripe')(functions.config().stripe.token);
const currency = functions.config().stripe.currency || 'USD';
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions


exports.newAppointments = functions.database.ref('/appointments/{uid}/{appointmentId}')
.onCreate((snapshot,context) => {

  var uid = context.params.uid;
  var appointmentId = context.params.appointmentId;
  var tokenList;

  return admin.database().ref('/users/' + uid).once('value', snapshot => {
    var user = snapshot.val();

    return admin.database().ref('administrators/bezDAO6izKPoKhpxBTfp4AGDv432').once('value', snapshot => {
     var dictionary = snapshot.val();
     var adminFCMToken = dictionary['fcmToken'];
     tokenList = [adminFCMToken, user.fcmToken];

      const payload = {
        "notification": {
          "body" : "New appointment has been created",
          "badge": "1"
        },
        "data": {
          "userId": uid,
          "appointmentId": appointmentId
        }
      };

      admin.messaging().sendToDevice(tokenList, payload)
        .then(response => {
          console.log('Successfully sent message to devices: ', response);
          // console.log(response.results[0].error);
          return 1;
        }).catch((error) => {
          console.log('Error sending message: ', error);
        });
       })
    })
})

exports.observeAppointments = functions.database.ref('/appointments/{uid}/{appointmentId}')
.onUpdate((snapshot,context) => {

  var uid = context.params.uid;
  var appointmentId = context.params.appointmentId;
  var appointmentInfo = snapshot.after.val();
  var statusTitle = appointmentInfo['statusTitle'];
  var statusInt = appointmentInfo['status'];
  var tokenList;

  return admin.database().ref('/users/' + uid).once('value', snapshot => {
    var user = snapshot.val();

    return admin.database().ref('administrators/bezDAO6izKPoKhpxBTfp4AGDv432').once('value', snapshot => {
     var dictionary = snapshot.val();
     var adminFCMToken = dictionary['fcmToken'];

     if (statusInt === 5 || statusInt === 3 || statusInt === 7) {
       tokenList = [adminFCMToken];
     } else {
       tokenList = [adminFCMToken, user.fcmToken];
     }

      const payload = {
        "notification": {
          "title" : "Appointment information updated",
          "body": "Status: " + statusTitle,
          "badge": "1"
        },
        "data": {
          "userId": uid,
          "appointmentId": appointmentId
        }
      };

      admin.messaging().sendToDevice(tokenList, payload)
        .then(response => {
          console.log('Successfully sent message to devices: ', response);
          // console.log(response.results[0].error);
          return 1;
        }).catch((error) => {
          console.log('Error sending message: ', error);
        });
       })
    })
})

exports.newNotes = functions.database.ref('/notes/{uid}/{noteId}')
.onCreate((snapshot, context) => {
    var uid = context.params.uid;
    var noteId = context.params.noteId;

    return admin.database().ref('/users/' + uid).once('value', snapshot => {
      var user = snapshot.val();

      const payload = {
        "notification": {
          "title" : "Note added",
          "body": "Appointment note has been added",
          "badge": "1"
        },
        "data": {
          "userId": uid,
          "noteId": noteId
        }
      };

      admin.messaging().sendToDevice(user.fcmToken, payload)
        .then(response => {
          console.log("Successfully sent message to device: ", response);
          return 1;
        }).catch((error) => {
          console.log("Error sending message:", error);
        });

      })
   })


exports.createNewStripeCustomer = functions.database.ref('users/{userId}').onCreate((snapshot, context) => {
  var user = snapshot.val();

  return stripe.customers.create({
    email: user.email,
  }).then((customer) => {
    return admin.database().ref(`/stripe_customers/${context.params.userId}/customer_id`).set(customer.id);
  });
});

// Add a payment source (card) for a user by writing a stripe payment source token to Realtime database
exports.addPaymentSource = functions.database.ref('/stripe_customers/{uid}/sources/sourceId')
.onWrite((change, context) => {
  const sourceId = change.after.val();
  if (sourceId === null){
    return null;
  }

  return admin.database().ref(`/stripe_customers/${context.params.uid}/customer_id`)
      .once('value').then((snapshot) => {
        const customerId = snapshot.val();
         stripe.customers.createSource(customerId, {
              source: sourceId,
              function(err, source) {
                if (err === null) {
                  console.log('source creation response: ', source);
                } else {
                  console.log('Error creating source for customer: ', err)
                }
              }
          });

          stripe.customers.update(customerId, { default_source: sourceId });
      return 1;
    })
  });

// Remove payment source for a user by removing a stripe payment source token to Realtime database
exports.removePaymentSource = functions.database.ref('/stripe_customers/{uid}/sources/sourceId')
.onDelete((snapshot, context) => {
  const sourceId = snapshot.val();

  return admin.database().ref(`/stripe_customers/${context.params.uid}/customer_id`)
      .once('value').then((snapshot) => {
      const customerId = snapshot.val();
      stripe.customers.deleteSource(customerId,
          sourceId,
          (err, source) => {
             if (err === null) {
               console.log('source deletion response: ', source);
             } else {
               console.log('Error deleting source for customer: ', err)
             }
           }
         );

//         stripe.customers.deleteSource(customerId, "src_1E4NOoApNy7gvZEoqSzTyLWE");
         return 1;
       })
  });


// Charge the Stripe customer whenever an amount is written to the Realtime database
exports.createStripeCharge = functions.database.ref('/stripe_customers/{uid}/charges/{id}')
    .onCreate((snapshot, context) => {
      const chargeDictionary = snapshot.val();
      const uid = context.params.uid;
      const id = context.params.id;

      return admin.database().ref('/stripe_customers/' + uid + '/customer_id')
          .once('value').then((snapshot) => {
          const customerId = snapshot.val();

            stripe.charges.create({
              customer: customerId,
              currency: "usd",
              description: chargeDictionary["description"],
              amount: chargeDictionary["amount"],
              source: chargeDictionary["source"]

            }, (err, charge) => {
              if (err === null) {
                console.log('charge completion response: ', charge);
                 var ref = admin.database().ref('/stripe_customers/' + uid + '/charges/' + id);
                 ref.update({response: charge});
          //       sendChargeResponseToDevice(uid, charge["status"]);

              } else {
                console.log('Error deleting source for customer: ', err)
                }
              }
            )
            return 1;
        })
  });

    function sendChargeResponseToDevice(uid, status){
      return admin.database().ref('/users/' + uid).once('value', snapshot => {
        var user = snapshot.val();

        const payload = {
          "data": {
            "response": status
          }
        };

      admin.messaging().sendToDevice(user.fcmToken, payload)
        .then(response => {
          console.log('Successfully sent charge response to device: ', response);
    //       console.log(response.results[0].error);
          return 1;
        }).catch((error) => {
          console.log('Error sending message: ', error);
        })
      });
    }

        // To keep on top of errors, we should raise a verbose error report with Stackdriver rather
        // than simply relying on console.error. This will calculate users affected + send you email
        // alerts, if you've opted into receiving them.
        // [START reporterror]
        function reportError(err, context = {}) {
          // This is the name of the StackDriver log stream that will receive the log
          // entry. This name can be any valid log stream name, but must contain "err"
          // in order for the error to be picked up by StackDriver Error Reporting.
          const logName = 'errors';
          const log = logging.log(logName);

          // https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
          const metadata = {
            resource: {
              type: 'cloud_function',
              labels: {function_name: process.env.FUNCTION_NAME},
            },
          };

          // https://cloud.google.com/error-reporting/reference/rest/v1beta1/ErrorEvent
          const errorEvent = {
            message: err.stack,
            serviceContext: {
              service: process.env.FUNCTION_NAME,
              resourceType: 'cloud_function',
            },
            context: context,
          };

          // Write the error log entry
          return new Promise((resolve, reject) => {
            log.write(log.entry(metadata, errorEvent), (error) => {
              if (error) {
               return reject(error);
              }
              return resolve();
            });
          });
        }
        // [END reporterror]

        // Sanitize the error message for the user
        function userFacingMessage(error) {
          return error.type ? error.message : 'An error occurred, developers have been alerted';
        }
