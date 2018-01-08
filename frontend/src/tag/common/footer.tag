<common-footer>
  <footer class="{ hidden: this.hideFooter }">
    <span>
      β期間中はリモート データベースの3重冗長化を行っていません。データロストにご注意ください。
      BitZenyによる寄付を受け付けています: ZpiKxkLZTmzVyiFPmNhfM6ivNkiaa2gGPd
    </span>
    <button id="footer-close" onclick="{ this.onClickButton }">
      ✕
    </button>
  </footer>

  <style>
    footer {
      position: fixed;
      bottom: 0;
      left: 0;
      z-index: 9999;
      font-size: 12px;
      /*width: 80vw;*/
      width: 100vw;
      height: 16px;
      background-color: rgba(55, 129, 115, 1.0);
      color: rgb(255, 255, 255);
      overflow: hidden;
      /*border-top-right-radius: calc(16px / 2);*/
      box-shadow: 1px 0 2px 0 rgba(0, 0, 0, 0.14),
                  1px 0 5px 0 rgba(0, 0, 0, 0.12),
                  1px 0 1px -2px rgba(0, 0, 0, 0.2);
      transition: all ease 0.5s;
    }

    footer.hidden {
      bottom: -16px;
    }

    footer span {
      display: inline-block;
      white-space: nowrap;
      padding-left: 100%;
      padding-right: 3rem;
      animation: marquee 30s linear infinite;
      line-height: 16px;
      vertical-align: text-bottom;
    }

    #footer-close {
      position: absolute;
      top: 0;
      bottom: 0;
      left: 0;
      width: 16px;
      height: 16px;
      padding: 0;
      margin: 0;
      z-index: 1;
      background-color: rgba(55, 129, 115, 1.0);
      color: rgb(255, 255, 255);
      border: none;
      line-height: 12px;
    }

    @keyframes marquee {
      from {
        transform: translate3d(0, 0, 0);
      }
      to {
        transform: translate3d(-100%, 0, 0);
      }
    }
  </style>

  <script>
    const self = this;

    this.hideFooter = false;

    onClickButton() {
      this.hideFooter = true;
    }
  </script>
</common-footer>
