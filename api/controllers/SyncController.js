/**
 * SyncController
 *
 * @description :: Server-side logic for managing syncs
 * @help        :: See http://sailsjs.org/#!/documentation/concepts/Controllers
 */

module.exports = {
  download: async (req, res) => {
	  const username = req.access_token.username;

	  let syncObj = await Sync.findOne({
      username
	  });
	  if(!syncObj) {
      syncObj = await Sync.create({
        username,
        nippo: '',
      });
    }

    res.ok({
      username: syncObj.username,
      nippo: syncObj.nippo,
    });
  },

  upload: async (req, res) => {
    const username = req.access_token.username;

    let syncObj = await Sync.findOne({
      username
    });
    if(!syncObj) {
      syncObj = await Sync.create({
        username,
        nippo: '',
      });
    } else {
      syncObj = await Sync.update({
        id: syncObj.id,
      }, {
        nippo: req.body.nippo,
      });
    }

    res.ok({
      username,
      nippo: req.body.nippo,
    });
  }
};

