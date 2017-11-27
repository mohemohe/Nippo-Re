<common-edit>
  <div class="row">
    <form class="col s12">
      <div class="row">
        <div class="input-field col m9 s12">
          <i class="material-icons prefix">title</i>
          <input id="title" type="text" class="validate active nippo-input" value="{ this.title }">
          <label for="title">タイトル</label>
        </div>
        <div class="input-field col m3 s12">
          <i class="material-icons prefix">today</i>
          <input value="{ this.date }" id="date" type="text" class="datepicker active nippo-input">
          <label for="date"></label>
        </div>
      </div>
      <div class="row">
        <div class="input-field col m6 s12">
          <textarea id="markdown" class="materialize-textarea active nippo-input" >{ this.body }</textarea>
          <label for="markdown">本文 (HTML / Markdown)</label>
        </div>
        <div class="col m6 hide-on-small-only">
          <div id="md2html" class="markdown-body" />
        </div>
      </div>
    </form>

    <div id="save-button">
      <a class="btn-floating btn-large waves-effect waves-light red"><i class="material-icons">save</i></a>
    </div>
  </div>

  <style>
    #save-button {
      position: fixed;
      bottom: 1em;
      right: 1em;
    }

    input, textarea {
      font-size: 16px !important;
    }

    .markdown-body {
      box-sizing: border-box;
      min-width: 200px;
      max-width: 980px;
      margin: 0 auto;
      padding: 45px;
    }

    .markdown-body ul li {
      list-style: outside !important;
    }

    @media (max-width: 767px) {
      .markdown-body {
        padding: 15px;
      }
    }
  </style>

  <script>
    import {EventWorker} from "../../js/eventWorker";

    const self = this;
    const today = new Date();

    this.id = null;
    this.title = '';
    this.date = `${today.getFullYear()}/${today.getMonth() + 1}/${today.getDate()}`;
    this.body = '';

    onInput() {
      self.title = $('#title').val();
      self.date = $('#date').val();
      self.body = $('#markdown').val();
      EventWorker.event.trigger('md2html:raise', self.body);
    }

    md2htmlDone(html) {
      riot.mount('div#md2html', 'common-raw', {content: html});
    }

    nippoSaveExec() {
      if(self.title === '') {
        return Materialize.toast('タイトルを入力してください', 5000);
      }

      if(self.date === '') {
        return Materialize.toast('日付を入力してください', 5000);
      }

      if(self.body === '') {
        return Materialize.toast('本文を入力してください', 5000);
      }

      EventWorker.event.trigger('nippoSave:raise', {
        id: self.id,
        title: self.title,
        date: self.date.split('/').join(''),
        body: self.body,
      });
    }

    nippoSaveDone(id) {
      self.id = id;
      Materialize.toast('ローカル データベースに保存しました', 5000);

      if(localStorage.autoSyncRemoteDatabase) {
        EventWorker.event.trigger('syncExportDB:raise', localStorage.e2eEncPassword);
      }
    }

    nippoSaveError() {
      Materialize.toast('ローカル データベースへの保存に失敗しました', 5000);
    }

    getNippoDone(nippo) {
      self.id = nippo.id;
      self.title = nippo.title;
      self.date = `${nippo.date.substring(0, 4)}/${nippo.date.substring(4, 6)}/${nippo.date.substring(6, 8)}`;
      self.body = nippo.body;
      EventWorker.event.trigger('md2html:raise', self.body);
      self.update();
      Materialize.updateTextFields();
      $('#title').trigger('keydown');
      $('#date').trigger('keydown');
      $('#markdown').trigger('keydown');
      Materialize.updateTextFields();
    }

    getNippoError() {
      Materialize.toast('ローカル データベースの取得に失敗しました', 5000);
    }

    hookCtrlS(event) {
      if((event.ctrlKey || event.metaKey) && event.which == 83) {
        self.nippoSaveExec();

        event.preventDefault();
        return false;
      }
    }

    exportRemoteDBDone() {
      Materialize.toast('リモート データベースにエクスポートしました', 5000);
    }

    exportRemoteDBError() {
      Materialize.toast('リモート データベースへのエクスポートに失敗しました', 5000);
    }

    dispose() {
      EventWorker.event.off('md2html:done', self.md2htmlDone);
      EventWorker.event.off('nippoSave:done', self.nippoSaveDone);
      EventWorker.event.off('nippoSave:error', self.nippoSaveError);
      EventWorker.event.off('nippoGet:done', self.getNippoDone);
      EventWorker.event.off('nippoGet:error', self.getNippoError);
      EventWorker.event.off('syncExportDB:done', self.exportRemoteDBDone);
      EventWorker.event.off('syncExportDB:error', self.exportRemoteDBError);
      $('.nippo-input').off('keyup', self.onInput);
      $('#save-button').off('click', self.nippoSaveExec);
      $(window).off('keydown', self.hookCtrlS);
    }

    this.on('mount', () => {
      $('.datepicker').pickadate({
        monthsFull:  ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
        monthsShort: ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"],
        weekdaysFull: ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"],
        weekdaysShort:  ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"],
        weekdaysLetter: ["日", "月", "火", "水", "木", "金", "土"],
        labelMonthNext: "翌月",
        labelMonthPrev: "前月",
        labelMonthSelect: "月を選択",
        labelYearSelect: "年を選択",
        today: "今日",
        clear: "クリア",
        close: "閉じる",
        format: "yyyy/mm/dd",
        onClose: function( arg ){
          self.date = $('#date').val();
        }
      });

      EventWorker.event.on('md2html:done', self.md2htmlDone);
      EventWorker.event.on('nippoSave:done', self.nippoSaveDone);
      EventWorker.event.on('nippoSave:error', self.nippoSaveError);
      EventWorker.event.on('nippoGet:done', self.getNippoDone);
      EventWorker.event.on('nippoGet:error', self.getNippoError);
      EventWorker.event.on('syncExportDB:done', self.exportRemoteDBDone);
      EventWorker.event.on('syncExportDB:error', self.exportRemoteDBError);
      $('.nippo-input').on('keyup', self.onInput);
      $('#save-button').on('click', self.nippoSaveExec);
      $(window).on('keydown', self.hookCtrlS);

      const id = parseInt(self.parent.opts.nippoId, 10);
      if(!isNaN(id)) {
        EventWorker.event.trigger('nippoGet:raise', id);
      }
    });

    this.on('before-unmount', () => {
      self.dispose();
    });
  </script>
</common-edit>
