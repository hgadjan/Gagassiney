'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');  
const config = functions.config();

admin.initializeApp(config.firebase);


functions.auth.user().onCreate(event => {
  const user = event.data;
  const userRef = admin.database().ref('/users').child(user.uid);
  
  return userRef.update(user);
});

exports.createUser = functions.firestore
  .document('users/{userId}')
  .onCreate((snap, context) => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    const newValue = snap.data();
    var user = admin.firestore().collection('/users')
    .doc(context.params.userId);

    // access a particular field as you would any JS property
    const name = newValue.name+"-Test";
    admin.messaging().subscribeToTopic(newValue.token, 'events').then(data=>{
      user.collection('topics').doc('events').set({topic:'events', 'subscribe': true});
      return user.get();
    }).catch(er => console.log(er));
  });





// exports.new_eleminatoire_combat = functions.firestore
//   .document('editions/{edition_id}/combats_eleminatoire/{combat_id}')
//   .onCreate((snap, context) => {
//     const data = snap.data();
    
//     if(data.type === -1){
//       return true;
//     }

//     var combatRef = admin.firestore().collection('/editions/'+context.params.edition_id+'/combats_eleminatoire');


//     // var date = new Date(data.date);
//     // console.log('Ma nouvelle date', data.date)
//     // var date2 = date.getFullYear()+'-'+(date.getMonth()+1)+'-'+date.getDate();
//     // var matin = new Date(date2);
//     // matin.setHours(8,0,0,0);
    
//     console.log('hhhhhhhhhhhhhhh', data.type_combat_code+'_'+data.numero+'_sys')
//     var doc1Ref = combatRef.doc(data.type_combat_code);
//     doc1Ref.get().then((docSnapshot) => {
//       if (!docSnapshot.exists) {
//         console.log('It does not exist')
//          doc1Ref.set({
//             'type': -1,
//             'content': data.type_combat_libele,
//             'type_combat_code': data.type_combat_code,
//             'edition': context.params.edition_id,
//             // 'date': data.date,
//             'numero': 0
//           }).then((d)=>{
//             console.log(d);
//             return d;
//           }).catch((er) => {
//             console.log(er)
//           });
//       }
//       return true;
//     }).catch((er) => {
//       console.log(er)
//     });
    
//     return true;
//   });

  exports.new_regional_combat = functions.firestore
  .document('editions/{edition_id}/combat_regionals/{combat_id}')
  .onCreate((snap, context) => {
    const data = snap.data();
    
    if(data.type === -1){
      return true;
    }

    var combatRef = admin.firestore().collection('/editions/'+context.params.edition_id+'/combat_regionals');


    var date = new Date(data.date);
    console.log('Ma nouvelle date', data.date)
    var date2 = date.getFullYear()+'-'+(date.getMonth()+1)+'-'+date.getDate();
    var matin = new Date(date2);
    matin.setHours(8,0,0,0);

    var soir = new Date(date2);
    soir.setHours(15,0,0,0);
    
    var doc1Ref = combatRef.doc('journee_'+data.journee+'_matin');
    var doc2Ref = combatRef.doc('journee_'+data.journee+'_soir');
    
    doc1Ref.get().then((docSnapshot) => {
      if (!docSnapshot.exists) {
         doc1Ref.set({
            'type': -1,
            // 'timestamp': matin.getTime().toString(),
            'content': 'Matin',
            'edition': context.params.edition_id,
            'journee': data.journee,
            'date': data.date,
            'numero': 0
          }).then((d)=>{
            console.log(d);
            return d;
          }).catch((er) => {
            console.log(er)
          });
      }
      return true;
    }).catch((er) => {
      console.log(er)
    });


    doc2Ref.get().then((docSnapshot) => {
      if (!docSnapshot.exists) {
         doc2Ref.set({
            'type': -1,
            // 'timestamp': soir.getTime().toString(),
            'content': 'Aprés Midi',
            'edition': context.params.edition_id,
            'journee': data.journee,
            'date': data.date,
            'numero': 3
          }).then((d)=>{
            console.log(d);
            return d;
          }).catch((er) => {
            console.log(er)
          });
      }
      return true;
    }).catch((er) => {
      console.log(er)
    });
    
    return true;
  });