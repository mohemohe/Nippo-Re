import Dexie from 'dexie';

const IDBExportImport = require("indexeddb-export-import");

let db;

export class IndexedDb {
  static initialize() {
    if(!db) {
      db = new Dexie("NippoRe");
      db.version(1).stores({
        nippo: '++id,updated_at,title,date,body'
      });
    }

    window.IndexedDb = this;
  }

  static get dexie() {
    return db;
  }

  static import(jsonString) {
    return new Promise(resolve => {
      db.open().then(() => {
        const idb_db = db.backendDB();

        IDBExportImport.clearDatabase(idb_db, (error) => {
          if(error) {
            return resolve(false);
          }

          IDBExportImport.importFromJsonString(idb_db, jsonString, (err) => {
            if (err) {
              return resolve(false);
            } else {
              return resolve(true);
            }
          });
        });
      });
    });
  }

  static export() {
    return new Promise(resolve => {
      db.open().then(() => {
        const idb_db = db.backendDB();

        IDBExportImport.exportToJsonString(idb_db, (error, jsonString) => {
          if(error) {
            return resolve(null);
          }

          resolve(jsonString);
        });
      }).catch(() => {
        return resolve(null);
      });
    });
  }
}


