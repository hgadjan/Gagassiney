// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:gagasiney/models/edition.dart';

// class KokowaProvider {
//   KokowaProvider();

//   static Stream<QuerySnapshot> getjourneeCombats(int edition, int journee) {
//     Firestore db = Firestore.instance;
//     Query strFormations;
//     if(journee == 0){
//       strFormations = db.collection('editions/$edition/combat_regionals').orderBy('journee').orderBy('numero');
//     }else{
//       strFormations = db.collection('editions/$edition/combat_regionals').where('journee', isEqualTo: journee).orderBy('numero');
//     }
//     return strFormations.snapshots();
//   }

//   static Stream<QuerySnapshot> getCombats(int edition, CombatRegional combatRegional) {
//     Firestore db = Firestore.instance;
//     Query strFormations = db.collection('editions/$edition/combat_regionals/journee_${combatRegional.journee}_combat_${combatRegional.numero}/combats').orderBy('numero');

//     return strFormations.snapshots();
//   }

//   static Stream<QuerySnapshot> getEleminatoireCombats(int edition, String type_combat) {
//     Firestore db = Firestore.instance;
//     Query strFormations = db.collection('editions/$edition/combats_eleminatoire').where('type_combat_code', isEqualTo: type_combat).orderBy('numero');

//     return strFormations.snapshots();
//   }

//    static Stream<QuerySnapshot> getEleminatoireTypesCombat() {
//     Firestore db = Firestore.instance;
//     Query strFormations = db.collection('types_combats_eleminatoire').orderBy('code', descending: true);

//     return strFormations.snapshots();
//   }

//   static Stream<QuerySnapshot> getLutteurs(int edition, String regionCode) {
//     Firestore db = Firestore.instance;
//     DocumentReference region = db.document('regions/$regionCode');
//     Query lutteurs = db.collection('editions/$edition/atheletes')
//     .where('region', isEqualTo: region)
//     .orderBy('type_athelete').orderBy('nom');
    
//     return lutteurs.snapshots();
//   }

//   static Stream<QuerySnapshot> getLutteurInvaincus(Edition edition) {
//     Firestore db = Firestore.instance;
//     Query lutteurs = db.collection('editions/${edition.annee}/atheletes').where('en_phase2', isEqualTo: true).orderBy('region').orderBy('nom');
    
//     return lutteurs.snapshots();
//   }

//   static Future<DocumentSnapshot> getAppActiveVersion(String app_version) {
//     Firestore db = Firestore.instance;
//     DocumentReference app = db.collection('app_versions').document(app_version);
    
//     return app.get();
//   }
// }
