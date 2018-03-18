<page-list>
  <div class="container">
    <div id="upper-container" class="row">
      <div class="col s12 m7">
        <ul class="pagination">
          <li class="waves-effect" onclick="{ minusPaginateIndex }"><a href="javascript:void(0);"><i class="material-icons">chevron_left</i></a></li>
          <span each="{ paginate }">
            <li class="{ isActive ? 'active' : '' } waves-effect" onclick="{ changePaginateIndex }"><a href="javascript:void(0);">{ number }</a></li>
          </span>
          <li class="waves-effect" onclick="{ plusPaginateIndex }"><a><i class="material-icons">chevron_right</i></a></li>
        </ul>
      </div>
      <form class="col s12 m5 right">
        <div id="search-input-field" class="input-field">
          <i class="material-icons prefix">search</i>
          <input id="search" type="text" class="validate">
          <label for="search">検索</label>
        </div>
      </form>
    </div>

    <div class="row">
      <div class="col s12">
        <div each="{ list }">
          <div class="card">
            <div class="card-content">
              <div class="card-title-container">
                <h4><a class="card-title teal-text">{ title }</a></h4>
                <h6 class="right">{ date.substring(0, 4) + '/' + date.substring(4, 6) + '/' + date.substring(6, 8) }</h6>
              </div>
              <p><common-raw content="{body.substring(0, 140)} {body.length > 140 ? '...' : ''}"/></p>
              <a class="waves-effect waves-red btn-floating red red-text text-lighten-2 right clearfix" href="{ '#/nippo/edit/' + id }"><i class="material-icons">mode_edit</i></a>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col s12">
        <ul class="pagination">
          <li class="waves-effect" onclick="{ minusPaginateIndex }"><a href="javascript:void(0);"><i class="material-icons">chevron_left</i></a></li>
          <span each="{ paginate }">
            <li class="{ isActive ? 'active' : '' } waves-effect" onclick="{ changePaginateIndex }"><a href="javascript:void(0);">{ number }</a></li>
          </span>
          <li class="waves-effect" onclick="{ plusPaginateIndex }"><a><i class="material-icons">chevron_right</i></a></li>
        </ul>
      </div>
    </div>
  </div>

  <style>
    :scope input {
      font-size: 16px !important;
    }

    :scope #upper-container {
      margin-top: 1rem;
    }

    :scope #upper-container form {
      margin-top: -1rem;
    }

    /*:scope #upper-container .pagination {*/
      /*display: flex;*/
      /*align-items: center;*/
      /*flex: 1;*/
      /*margin: 0;*/
    /*}*/

    :scope #search {
      margin-bottom: 0 !important;
    }

    :scope #upper-container #search-input-field {
      width: 100%;
    }

    :scope .material-icons.prefix {
      line-height: 43px;
    }

    :scope .card-title-container {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
    }

    :scope .card-title-container > * {
      margin-top: 0;
    }

    :scope .card {
      margin-bottom: 2rem;
    }
  </style>

  <script>
    import {EventWorker} from "../../js/eventWorker";

    const self = this;

    this.paginateIndex = 1;
    this.offset = 0;
    this.limit = 10;
    this.paginate = [];
    this.list = [];
    this.totalNippoCount = 0;
    this.paginateLimit = 1;

    updateTotalNippoCount(count) {
      self.totalNippoCount = count;
      self.updatePaginate();
    }

    updateList(list) {
      list.sort((val1, val2) => {
        if (val1.date < val2.date){
          return 1;
        }else{
          return -1;
        }
      });
      list.forEach(nippo => {
        nippo.body = nippo.body.replace(/\n/g, '<br>');
      });
      self.list = list;
      self.update();
    }

    updatePaginate() {
      const paginateIndex = self.paginateIndex;
      self.offset = (paginateIndex - 1) * self.limit;
      self.paginate = [];

      self.paginateLimit = Math.ceil(self.totalNippoCount / self.limit);
      if (self.paginateLimit < 1) {
        self.paginateLimit = 1;
      }

      let lowerLimit = self.paginateIndex - 2;
      let upperLimit = self.paginateIndex + 2;
      if(self.paginateIndex <= 3) {
        lowerLimit = 1;
        upperLimit = 5;
      }
      if (self.paginateLimit < upperLimit) {
        lowerLimit = self.paginateLimit - 4;
        upperLimit = self.paginateLimit;
      }
      if (lowerLimit < 1) {
        lowerLimit = 1;
      }

      for(let i = lowerLimit; i <= upperLimit; i++) {
        self.paginate.push({
          number: i,
          isActive: i === paginateIndex,
        });
      }

      self.update();
    }

    changePaginateIndex(event) {
      self.paginateIndex = parseInt(event.target.innerHTML, 10);
      self.updatePaginate();
      self.raiseUpdateList();
    }

    minusPaginateIndex() {
      if(self.paginateIndex > 1) {
        self.paginateIndex--;
      }
      self.updatePaginate();
      self.raiseUpdateList();
    }

    plusPaginateIndex() {
      if (self.paginateIndex < self.paginateLimit) {
        self.paginateIndex++;
      }
      self.updatePaginate();
      self.raiseUpdateList();
    }

    errorList() {
      EventWorker.event.trigger('showToast', 'ローカル データベースの取得に失敗しました');
    }

    importRemoteDBDone() {
      EventWorker.event.trigger('showToast', 'リモート データベースからインポートしました');
      EventWorker.event.trigger('nippoList:raise', self.offset, self.limit);

      self.updatePaginate();
    }

    importRemoteDBError() {
      EventWorker.event.trigger('showToast', 'リモート データベースのインポートに失敗しました');
    }

    raiseUpdateList() {
      const keyword = $('#search').val();
      if (keyword && keyword === "") {
        EventWorker.event.trigger('nippoList:raise', self.offset, self.limit);
      } else {
        EventWorker.event.trigger('nippoSearch:raise', keyword, self.offset, self.limit);
      }
    }

    onSearch() {
      self.raiseUpdateList();
    }

    this.on('before-mount', () => {
      if(localStorage.auth_info && localStorage.autoSyncRemoteDatabase && JSON.parse(localStorage.autoSyncRemoteDatabase)) {
        if (localStorage.syncApiVersion && JSON.parse(localStorage.syncApiVersion) === 3) {
          EventWorker.event.trigger('syncImportDB:raise', localStorage.e2eEncPassword);
        } else {
          EventWorker.event.trigger('showToast', 'リモート データベースAPIが変更されました。');
          EventWorker.event.trigger('showToast', '再度インポートを行ってください。');
        }
      }
    });

    this.on('mount', () => {
      EventWorker.event.on('nippoList:done', self.updateList);
      EventWorker.event.on('nippoList:error', self.errorList);
      EventWorker.event.on('nippoCount:done', self.updateTotalNippoCount);
      EventWorker.event.on('nippoCount:error', self.errorList);
      EventWorker.event.on('syncImportDB:done', self.importRemoteDBDone);
      EventWorker.event.on('syncImportDB:error', self.importRemoteDBError);
      EventWorker.event.trigger('nippoList:raise', self.offset, self.limit);
      EventWorker.event.trigger('nippoCount:raise');

      $('#search').on('keyup', self.onSearch);

      self.updatePaginate();
    });

    this.on('before-unmount', () => {
      EventWorker.event.off('nippoList:done', self.updateList);
      EventWorker.event.off('nippoList:error', self.errorList);
      EventWorker.event.off('nippoCount:done', self.updateTotalNippoCount);
      EventWorker.event.off('nippoCount:error', self.errorList);
      EventWorker.event.off('syncImportDB:done', self.importRemoteDBDone);
      EventWorker.event.off('syncImportDB:error', self.importRemoteDBError);
    });
  </script>
</page-list>
