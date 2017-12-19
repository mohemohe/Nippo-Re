<page-list>
  <div class="container">
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

    <div class="row">
      <div class="col s12">
        <div class="collection">
          <div each="{ list }">
            <a class="collection-item" href="{ '#/nippo/edit/' + id }">
              <div class="row">
                <div class="col s8">
                  <h4 class="left">{ title }</h4>
                </div>
                <div class="col s4">
                  <h6 class="right">{ date.substring(0, 4) + '/' + date.substring(4, 6) + '/' + date.substring(6, 8) }</h6>
                </div>
              </div>
              <p>{ body.substring(0, 140) }</p>
            </a>
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

  <script>
    const self = this;

    this.paginateIndex = 1;
    this.offset = 0;
    this.limit = 10;
    this.paginate = [];
    this.list = [];

    updateList(list) {
      list.sort((val1, val2) => {
        if (val1.date < val2.date){
          return 1;
        }else{
          return -1;
        }
      });
      self.list = list;
      self.update();
    }

    updatePaginate() {
      const paginateIndex = self.paginateIndex;
      self.offset = (paginateIndex - 1) * self.limit;
      self.paginate = [];

      let lowerLimit = self.paginateIndex - 2;
      let upperLimit = self.paginateIndex + 2;
      if(self.paginateIndex <= 3) {
        lowerLimit = 1;
        upperLimit = 5;
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

      EventWorker.event.trigger('nippoList:raise', self.offset, self.limit);
    }

    minusPaginateIndex() {
      if(self.paginateIndex > 1) {
        self.paginateIndex--;
      }
      self.updatePaginate();

      EventWorker.event.trigger('nippoList:raise', self.offset, self.limit);
    }

    plusPaginateIndex() {
      self.paginateIndex++;
      self.updatePaginate();

      EventWorker.event.trigger('nippoList:raise', self.offset, self.limit);
    }

    errorList() {
      Materialize.toast('ローカル データベースの取得に失敗しました', 5000);
    }

    importRemoteDBDone() {
      Materialize.toast('リモート データベースからインポートしました', 5000);
      self.updatePaginate();
    }

    importRemoteDBError() {
      Materialize.toast('リモート データベースのインポートに失敗しました', 5000);
    }

    this.on('before-mount', () => {
      if(localStorage.auth_info && localStorage.autoSyncRemoteDatabase && JSON.parse(localStorage.autoSyncRemoteDatabase)) {
        EventWorker.event.trigger('syncImportDB:raise', localStorage.e2eEncPassword);
      }
    });

    this.on('mount', () => {
      EventWorker.event.on('nippoList:done', self.updateList);
      EventWorker.event.on('nippoList:error', self.errorList);
      EventWorker.event.trigger('nippoList:raise', self.offset, self.limit);
      EventWorker.event.on('syncImportDB:done', self.importRemoteDBDone);
      EventWorker.event.on('syncImportDB:error', self.importRemoteDBError);
      self.updatePaginate();
    });

    this.on('before-unmount', () => {
      EventWorker.event.off('nippoList:done', self.updateList);
      EventWorker.event.off('nippoList:error', self.errorList);
      EventWorker.event.off('syncImportDB:done', self.importRemoteDBDone);
      EventWorker.event.off('syncImportDB:error', self.importRemoteDBError);
    });
  </script>
</page-list>
