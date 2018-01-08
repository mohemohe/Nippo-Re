function createApiObj(nippo, username, id) {
  let updateObj = {
    username,
    nippoId: id || nippo.nippoId,
    date: nippo.date,
    title: nippo.title,
    body: nippo.body,
    isEncrypted: nippo.isEncrypted,
    isShared: nippo.isShared,
  };

  if(nippo.isShared) {
    updateObj.sharedPassword = nippo.sharedPassword || null;
    updateObj.sharedTitle = nippo.sharedTitle;
    updateObj.sharedBody = nippo.sharedBody;
  }

  return updateObj;
}

module.exports = {
  _import: async (req, res) => {
	  const username = req.access_token.username;
    let result;

	  let syncObj;
	  try {
	    syncObj = await Nippo.find({
        username
      });
      syncObj.forEach(nippo => {
        delete nippo.id;
        delete nippo.username;
        delete nippo.createdAt;
        delete nippo.updatedAt;
      });
      if (syncObj) {
        result = {
          status: 0,
          result: syncObj,
        };
      }
    } catch (e) {
      result = {
        status: 1,
        result: [],
      };
    }
    res.ok(result);
  },

  _export: async (req, res) => {
    const username = req.access_token.username;

    const nippos = req.body.nippos;
    if (!nippos) {
      return res.ok({
        status: 1,
        result: 'nippos seems missing'
      });
    }

    const nippoPromises = nippos.map(nippo => {
      const updateObj = createApiObj(nippo, username);

      return Nippo.updateOrCreate({
        username,
        nippoId: nippo.id || nippo.nippoId,
      }, updateObj);
    });

    try {
      await Promise.all(nippoPromises);
    } catch (e) {
      return res.ok({
        status: 1,
      });
    }

    res.ok({
      status: 0,
    });
  },

  _update: async (req, res) => {
    const username = req.access_token.username;
    const nippo = req.body.nippo;
    const id = req.param('id');

    if (isNaN(parseInt(id))) {
      return res.ok({
        status: 1,
        result: 'invalid id',
      });
    }

    if (!nippo) {
      return res.ok({
        status: 1,
        result: 'nippo seems missing',
      });
    }

    const updateObj = createApiObj(nippo, username, id);
    try {
      const result = await Nippo.updateOrCreate({
        username,
        nippoId: id,
      }, updateObj);

      delete result.id;
      delete result.username;
      delete result.createdAt;
      delete result.updatedAt;

      res.ok({
        status: 0,
        result,
      });
    } catch (e) {
      return res.ok({
        status: 1,
      });
    }
  },
};

