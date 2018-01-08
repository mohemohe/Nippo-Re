const uuid = require("uuid/v4");
const sha256 = require('js-sha256');
/**
 * Sync.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {
    username: {
      type: 'string',
      index: true,
    },
    nippoId: {
      type: 'integer',
      index: true,
    },
    date: {
      type: 'string',
    },
    title: {
      type: 'string',
    },
    body: {
      type: 'string',
    },
    isEncrypted: {
      type: 'boolean',
    },
    isShared: {
      type: 'boolean',
      index: true,
    },
    sharedPassword: {
      type: 'string',
    },
    sharedTitle: {
      type: 'string',
    },
    sharedBody: {
      type: 'string',
    },
    sharedHash: {
      type: 'string',
      index: true,
      defaultsTo: () => {
        return sha256(uuid());
      },
    },
  }

};

