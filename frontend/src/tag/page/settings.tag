<page-settings>
  <div class="container">
    <div class="row">
      <div class="col s12">

        <div class="collection">
          <div class="collection-header"><h4>IndexedDB</h4></div>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ importDB }">インポート</a>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ exportDB }">エクスポート</a>
          <a href="javascript:void(0)" class="collection-item waves-effect waves-teal" onclick="{ openDeleteAndInitializeDBModal }">リセット</a>
        </div>

      </div>
    </div>
  </div>

  <div id="modal" class="modal">
    <div class="modal-content">
      <h4>{ modalTitle }</h4>
      <p>{ modalMessage }</p>
    </div>
    <div class="modal-footer">
      <a href="javascript:void(0)" class="modal-action modal-close waves-effect waves-green btn-flat">OK</a>
    </div>
  </div>

  <style>
    .collection-header {
      border-bottom: 1px solid #e0e0e0;
    }

    .collection-header > h4 {
      padding-left: 1rem;
    }
  </style>

  <script>
    import {EventWorker} from "../../js/eventWorker";

    const self = this;

    self.modalTitle = null;
    self.modalMessage = null;

    importDB() {
      EventWorker.event.trigger('importNippo:exec');
    }

    importDBDone() {
      Materialize.toast('インポートしました', 5000);
    }

    importDBError() {
      Materialize.toast('インポートに失敗しました', 5000);
    }

    exportDB() {
      EventWorker.event.trigger('exportNippo:exec');
    }

    exportDBError() {
      Materialize.toast('エクスポートに失敗しました', 5000);
    }

    openDeleteAndInitializeDBModal() {
      self.modalTitle = 'リセット';
      self.modalMessage = 'やだ';

      self.openModal();
    }

    openModal() {
      self.update();
      $('#modal').modal('open');
    }

    this.on('mount', () => {
      EventWorker.event.on('importNippo:done', self.importDBDone);
      EventWorker.event.on('importNippo:error', self.importDBError);
      EventWorker.event.on('exportNippo:error', self.exportDBError);
      $('.modal').modal();
    })
  </script>
</page-settings>
