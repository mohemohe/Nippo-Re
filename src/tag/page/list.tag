<page-list>
  <div class="container">
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
        👇未実装だよ
      </div>
    </div>
    <div class="row">
      <div class="col s12">
        <ul class="pagination">
          <li class="waves-effect"><a href="javascript:void(0);"><i class="material-icons">chevron_left</i></a></li>
          <span each="{ paginate }">
            <li class="{ isActive ? 'active' : '' } waves-effect"><a href="javascript:void(0);">{ number }</a></li>
          </span>
          <li class="waves-effect"><a><i class="material-icons">chevron_right</i></a></li>
        </ul>
      </div>
    </div>
  </div>

  <script>
    const self = this;

    this.paginateIndex = 1;
    this.offset = 0;
    this.limit = 50;
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

    updatePaginate(offset) {
      const paginateIndex = self.paginateIndex;
      self.offset = paginateIndex * self.limit;
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

    errorList() {
      Materialize.toast('失敗しました', 5000);
    }

    this.on('mount', () => {
      EventWorker.event.on('listNippo:done', self.updateList);
      EventWorker.event.on('listNippo:error', self.errorList);
      EventWorker.event.trigger('listNippo:exec', self.offset, self.limit);
      self.updatePaginate();
    });

    this.on('unmount', () => {

    });
  </script>
</page-list>
