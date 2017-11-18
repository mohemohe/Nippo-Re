<common-edit>
  <div class="row">
    <form class="col s12">
      <div class="row">
        <div class="input-field col m9 s12">
          <i class="material-icons prefix">title</i>
          <input placeholder="タイトル" id="title" type="text" class="validate nippo-input" value="{ this.title }">
          <label for="title">タイトル</label>
        </div>
        <div class="input-field col m3 s12">
          <i class="material-icons prefix">today</i>
          <input placeholder="日付" value="{ this.date }" id="date" type="text" class="datepicker active nippo-input">
          <label for="date">日付</label>
        </div>
      </div>
      <div class="row">
        <div class="input-field col m6 s12">
          <textarea id="markdown" class="materialize-textarea nippo-input" >{ this.body }</textarea>
          <label for="markdown">Markdown</label>
        </div>
        <div class="col m6 hide-on-small-only">
          <div id="md2html" />
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
      EventWorker.event.trigger('md2html:exec', self.body);
    }

    md2htmlDone(html) {
      riot.mount('div#md2html', 'common-raw', {content: html});
    }

    saveNippoExec() {
      if(self.title === '') {
        return Materialize.toast('タイトルを入力してください', 5000);
      }

      if(self.date === '') {
        return Materialize.toast('日付を入力してください', 5000);
      }

      if(self.body === '') {
        return Materialize.toast('本文を入力してください', 5000);
      }

      EventWorker.event.trigger('saveNippo:exec', {
        id: self.id,
        title: self.title,
        date: self.date,
        body: self.body,
      });
    }

    saveNippoDone(id) {
      self.id = id;
      Materialize.toast('保存しました', 5000);
    }

    saveNippoError() {
      Materialize.toast('失敗しました', 5000);
    }

    getNippoDone(nippo) {
      self.id = nippo.id;
      self.title = nippo.title;
      self.date = `${nippo.date.substring(0, 4)}/${nippo.date.substring(4, 6)}/${nippo.date.substring(6, 8)}`;
      self.body = nippo.body;
      EventWorker.event.trigger('md2html:exec', self.body);
      self.update();
      Materialize.updateTextFields()
    }

    getNippoError() {
      Materialize.toast('失敗しました', 5000);
    }

    hookCtrlS(event) {
      if((event.ctrlKey || event.metaKey) && event.which == 83) {
        self.saveNippoExec();

        event.preventDefault();
        return false;
      }
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
        format: "yyyy-mm-dd",
        onClose: function( arg ){
          self.date = $('#date').val();
        }
      });

      EventWorker.event.on('md2html:done', self.md2htmlDone);
      EventWorker.event.on('saveNippo:done', self.saveNippoDone);
      EventWorker.event.on('saveNippo:error', self.saveNippoError);
      EventWorker.event.on('getNippo:done', self.getNippoDone);
      EventWorker.event.on('getNippo:error', self.getNippoError);
      $('.nippo-input').on('keyup', self.onInput);
      $('#save-button').on('click', self.saveNippoExec);
      $(window).on('keydown', self.hookCtrlS);

      const id = parseInt(self.parent.opts.nippoId, 10);
      if(!isNaN(id)) {
        EventWorker.event.trigger('getNippo:exec', id);
      }

      Materialize.updateTextFields()
    });

    this.on('unmount', () => {
      EventWorker.event.off('md2html:done', self.md2htmlDone);
      EventWorker.event.off('saveNippo:done', self.saveNippoDone);
      EventWorker.event.off('saveNippo:error', self.saveNippoError);
      EventWorker.event.off('getNippo:done', self.getNippoDone);
      EventWorker.event.off('getNippo:error', self.getNippoError);
      $('.nippo-input').off('keyup', self.onInput);
      $('#save-button').off('click', self.saveNippoExec);
      $(window).off('keydown', self.hookCtrlS);
    });
  </script>
</common-edit>
