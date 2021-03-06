<page-settings>
  <div class="container">
    <div class="row">
      <div class="col s12">
        <div class="collection">
          <div class="collection-header teal lighten-1 white-text"><h4>ローカル データベース</h4></div>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ importLocalDBModal }">インポート</a>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ exportLocalDBModal }">エクスポート</a>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ resetLocalDBModal }">リセット</a>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col s12">
        <div class="collection">
          <div class="collection-header teal lighten-1 white-text"><h4>リモート データベース</h4></div>
          <div class="collection-item row">
            <div class="input-field col s12">
              <input id="e2e-enc-password" type="password">
              <label for="e2e-enc-password">end to end暗号化パスワード</label>
            </div>
          </div>
          <div class="collection-item">
            <div class="switch right" style="margin-top:-.25rem">
              <label>
                <input type="checkbox" id="auto-export-to-remote-database">
                <span class="lever"></span>
              </label>
            </div>
            <div>自動でリモート データベースにインポート・エクスポートする</div>
            <p class="grey-text">
              ONにすると整合性のために現在のローカル データベースのデータをエクスポートします<br>
              リモート データベースのデータが必要な場合は先にインポートしてください
            </p>
          </div>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ importRemoteDBModal }">インポート</a>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ exportRemoteDBModal }">エクスポート</a>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ resetRemoteDBModal }">リセット</a>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col s12">
        <div class="collection">
          <div class="collection-header teal lighten-1 white-text"><h4>アカウント パスワード</h4></div>
          <div class="collection-item">
            <div class="row">
              <div class="input-field col s12">
                <input id="password" type="password" class="validate">
                <label for="password">パスワード</label>
              </div>
            </div>
            <div class="row">
              <div class="input-field col s12">
                <input id="password2" type="password" class="validate">
                <label for="password2">パスワード（確認）</label>
              </div>
            </div>
            <div class="row">
              <div class="input-field col s12">
                <button class="btn waves-effect waves-light right" onclick="{ updatePassword }">変更
                  <i class="material-icons right">send</i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div id="modal" class="modal modal-fixed-footer">
    <div class="modal-content">
      <h4>{ modalTitle }</h4>
      <pre>{ modalMessage }</pre>
    </div>
    <div class="modal-footer">
      <button if="{ modalNegativeText }" class="modal-action modal-close waves-effect waves-red btn-flat" onclick="{ modalNegativeFunction }">{ modalNegativeText }</button>
      <button class="modal-action modal-close waves-effect waves-green btn-flat" onclick="{ modalPositiveFunction }">{ modalPositiveText }</button>
      <!--<button class="modal-action modal-close waves-effect waves-green btn-flat">OK</button>-->
    </div>
  </div>

  <style>
    .collection-header {
      border-bottom: 1px solid #e0e0e0;
    }

    .collection-header > h4 {
      padding-left: 1rem;
    }

    input {
      font-size: 16px !important;
    }

    pre {
      font-family: Koruri;
      white-space: pre-wrap;
    }

    :scope h4 {
      margin: 0;
      padding : 1rem;
    }
  </style>

  <script>
    import {EventWorker} from "../../js/eventWorker";

    const self = this;

    self.modalTitle = null;
    self.modalMessage = null;
    self.modalPositiveText = null;
    self.modalPositiveFunction = null;
    self.modalNegativeText = null;
    self.modalNegaticeFunction = null;

    importLocalDBModal() {
      self.modalTitle = 'インポート';
      self.modalMessage = `ローカル データベースにJSONをインポートします
現在のローカル データベースのデータは削除されます`;
      self.modalPositiveText = 'OK';
      self.modalPositiveFunction = self.importLocalDB;
      self.modalNegativeText = 'キャンセル';
      self.modalNegativeFunction = self.voidFunction;

      self.openModal();
    }

    importLocalDB() {
      EventWorker.event.trigger('nippoImport:raise');
    }

    importLocalDBDone() {
      EventWorker.event.trigger('showToast', 'JSONをインポートしました');
    }

    importLocalDBError() {
      EventWorker.event.trigger('showToast', 'JSONのインポートに失敗しました');
    }

    exportLocalDBModal() {
      self.modalTitle = 'エクスポート';
      self.modalMessage = `ローカル データベースのデータをJSON形式でエクスポートします
エクスポートされるJSONは暗号化されていません`;
      self.modalPositiveText = 'OK';
      self.modalPositiveFunction = self.exportLocalDB;
      self.modalNegativeText = 'キャンセル';
      self.modalNegativeFunction = self.voidFunction;

      self.openModal();
    }

    exportLocalDB() {
      EventWorker.event.trigger('nippoExport:raise');
    }

    exportLocalDBError() {
      EventWorker.event.trigger('showToast', 'JSONのエクスポートに失敗しました');
    }

    resetLocalDBModal() {
      self.modalTitle = 'リセット';
      self.modalMessage = 'ローカル データベースのリセットは未実装です';
      self.modalPositiveText = 'OK';
      self.modalPositiveFunction = self.voidFunction;
      self.modalNegativeText = null;
      self.modalNegativeFunction = self.voidFunction;

      self.openModal();
    }

    importRemoteDBModal() {
      self.modalTitle = 'インポート';
      self.modalMessage = `リモート データベースのデータを、ローカル データベースにインポートします
現在のローカル データベースのデータは削除されます
end to end暗号化のパスワードが設定されている場合は、インポートされるJSONがブラウザで復号されます`;
      self.modalPositiveText = 'OK';
      self.modalPositiveFunction = self.importRemoteDB;
      self.modalNegativeText = 'キャンセル';
      self.modalNegativeFunction = self.voidFunction;

      self.openModal();
    }

    importRemoteDB() {
      EventWorker.event.trigger('syncImportDB:raise', $('#e2e-enc-password').val());
    }

    importRemoteDBDone() {
      EventWorker.event.trigger('showToast', 'リモート データベースからインポートしました');
    }

    importRemoteDBError() {
      EventWorker.event.trigger('showToast', 'リモート データベースのインポートに失敗しました');
    }

    exportRemoteDBModal() {
      self.modalTitle = 'エクスポート';
      self.modalMessage = `ローカル データベースのデータをリモート データベースにエクスポートします
現在のリモート データベースのデータは削除されます
end to end暗号化のパスワードが設定されている場合は、エクスポートするJSONをAES256-CTRでブラウザで暗号化します`;
      self.modalPositiveText = 'OK';
      self.modalPositiveFunction = self.exportRemoteDB;
      self.modalNegativeText = 'キャンセル';
      self.modalNegativeFunction = self.voidFunction;

      self.openModal();
    }

    exportRemoteDB() {
      EventWorker.event.trigger('syncExportDB:raise', $('#e2e-enc-password').val());
    }

    exportRemoteDBDone() {
      EventWorker.event.trigger('showToast', 'リモート データベースにエクスポートしました');
    }

    exportRemoteDBError() {
      EventWorker.event.trigger('showToast', 'リモート データベースへのエクスポートに失敗しました');
    }

    resetRemoteDBModal() {
      self.modalTitle = 'リセット';
      self.modalMessage = 'リモート データベースのリセットは未実装です';
      self.modalPositiveText = 'OK';
      self.modalPositiveFunction = self.voidFunction;
      self.modalNegativeText = null;
      self.modalNegativeFunction = self.voidFunction;

      self.openModal();
    }

    updatePassword() {
      const password = $("#password").val();
      const confirmPassword = $("#password2").val();

      if (password === "") {
        EventWorker.event.trigger('showToast', '空のパスワードは設定できません');
        return;
      }

      if (password !== confirmPassword) {
        EventWorker.event.trigger('showToast', 'パスワードが一致していません');
        return;
      }

      EventWorker.event.trigger('updatePassword:raise', password);
    }

    updatePasswordDone() {
      EventWorker.event.trigger('showToast', 'パスワードを変更しました');
    }

    updatePasswordError() {
      EventWorker.event.trigger('showToast', 'パスワードの変更に失敗しました');
    }

    openModal() {
      self.update();
      $('#modal').modal('open');
    }

    voidFunction() {

    }

    onInput(event) {
      localStorage.e2eEncPassword = $('#e2e-enc-password').val();
    }

    onChange(event) {
      const checked = event.target.checked;
      localStorage.autoSyncRemoteDatabase = checked;
      if(checked) {
        self.exportRemoteDB();
      }
    }

    this.on('mount', () => {
      EventWorker.event.on('nippoImport:done', self.importLocalDBDone);
      EventWorker.event.on('nippoImport:error', self.importLocalDBError);
      EventWorker.event.on('nippoExport:error', self.exportLocalDBError);
      EventWorker.event.on('syncImportDB:done', self.importRemoteDBDone);
      EventWorker.event.on('syncImportDB:error', self.importRemoteDBError);
      EventWorker.event.on('syncExportDB:done', self.exportRemoteDBDone);
      EventWorker.event.on('syncExportDB:error', self.exportRemoteDBError);
      EventWorker.event.on('updatePassword:done', self.updatePasswordDone);
      EventWorker.event.on('updatePassword:error', self.updatePasswordError);
      $('#e2e-enc-password').on('keyup', self.onInput);
      $('#auto-export-to-remote-database').on('change', self.onChange);
      $('.modal').modal();

      $('#e2e-enc-password').trigger('keydown');

      $('#e2e-enc-password').val(localStorage.e2eEncPassword);
      const checkbox = document.querySelector('#auto-export-to-remote-database');
      if (localStorage.autoSyncRemoteDatabase && JSON.parse(localStorage.autoSyncRemoteDatabase)) {
        checkbox.checked = true;
      }

      if (Materialize && Materialize.updateTextFields) {
        Materialize.updateTextFields();
      }
    });

    this.on('before-unmount', () => {
      EventWorker.event.off('nippoImport:done', self.importLocalDBDone);
      EventWorker.event.off('nippoImport:error', self.importLocalDBError);
      EventWorker.event.off('nippoExport:error', self.exportLocalDBError);
      EventWorker.event.off('syncImportDB:done', self.importRemoteDBDone);
      EventWorker.event.off('syncImportDB:error', self.importRemoteDBError);
      EventWorker.event.off('syncExportDB:done', self.exportRemoteDBDone);
      EventWorker.event.off('syncExportDB:error', self.exportRemoteDBError);
      EventWorker.event.off('updatePassword:done', self.updatePasswordDone);
      EventWorker.event.off('updatePassword:error', self.updatePasswordError);
    });
  </script>
</page-settings>
