import * as _ from 'lodash';
import { EventWorker } from '../eventWorker';
import { IndexedDb } from '../indexedDb';

const welcomeBody = `# Nippo:Reへようこそ！

※ この日暮里は新規で何か書くと自動で消えます

## Nippo:Re とは？

Nippo:Re はブラウザー内蔵のIndexed DBにテキストを保存する、セキュアなメモ サイトです。
初期設定では、アプリが動作するためのデータを読み込む以外はサーバーと通信していません。

サーバーにメモのバックアップを保存することができます。
[新規登録](#/signup)ページからアカウントを登録してください。
登録後は、[設定](#/settings)ページのリモート データベースからエクスポートできます。
エンドツーエンド暗号化パスワードを設定すると、AES 256bitによる金融機関レベルの強力な暗号化をローカルで行います。

## Nippo:Reでできること

### アカウント未登録（オフラインモード）

- メモの作成
- メモの検索
- メモのJSONエクスポートとインポート

### アカウント登録（オンラインモード）

- アカウント未登録でできること全て
- リモートDBへのメモのバックアップとリストア
- メモの共有（E2E暗号化が有効な場合は別途共有用E2E暗号化パスワードが必要）

## Nippo:Reで使えるフォーマット

Markdownまたは制限付きHTMLで書くことができます。

### Markdown

[GitHub Flavored Markdown](https://github.github.com/gfm/ "GitHub Flavored Markdown Spec")におおむね準拠しています。

| 例えば   | テーブルが |
| -------- | ---------- |
| 使えます | 。         |

### 制限付きHTML

\`<script>\`タグを除くタグに対応しています。
例えば、

<style>
.zzzz-sample-style {
  background: #44aaff;
  color: #ffffff;
  padding: 2rem;
  font-size: 1.5rem;
}
</style>

<div class='zzzz-sample-style'>サンプルのdiv要素です。</div>

<marquee><h1>🍣 🍣 🍣 🍣 🍣 </h1></marquee>

のような感じで書けます。

`;

const demoNippore = {
  id: -1,
  date: "19700101",
  title: "Nippo:Reへようこそ！",
  body: welcomeBody,
  isShared: false,
  sharedHash: "",
  sharedPassword: "",
};

export function nippoSave(args) {
  let dbObj = {
    title: args.title,
    date: args.date.split('-').join(''),
    body: args.body,
    isShared: args.isShared,
    sharedPassword: args.sharedPassword,
    updated_at: new Date()
  };
  if (args.id !== null) {
    dbObj.id = args.id;
  }
  if (args.sharedHash && args.sharedHash !== '') {
    dbObj.sharedHash = args.sharedHash;
  }

  IndexedDb.dexie.nippo.put(dbObj).then((id) => {
    console.log('onNippoSave:', id);
    EventWorker.event.trigger('nippoSave:done', id, dbObj);
  }).catch(() => {
    EventWorker.event.trigger('nippoSave:error');
  });
}

export function nippoUpdate(args) {
  const id = args.id;
  delete args.id;

  IndexedDb.dexie.nippo.get(id).then((result) => {
    return result;
  }).then(nippo => {
    return _.merge(nippo, args);
  }).then(updateObj => {
    return IndexedDb.dexie.nippo.update(id, updateObj);
  }).catch((e) => {
    console.error(e);
  });
}

export function nippoList(offset, limit) {
  IndexedDb.dexie.nippo.orderBy('date').reverse().offset(offset).limit(limit).toArray().then((result) => {
    if (offset === 0 && result.length === 0) {
      result.push(demoNippore);
    }
    EventWorker.event.trigger('nippoList:done', result);
  }).catch(() => {
    EventWorker.event.trigger('nippoList:error');
  });
}

export function nippoSearch(keyword, offset, limit) {
  if (keyword === "" || keyword === '　') {
    return nippoList(offset, limit);
  }

  const replacedKeyword = keyword.replace(/　/g, ' ');
  const keywordArray = replacedKeyword.split(' ').filter(value => {
    return value !== '';
  });

  const isContain = (ary, target) => {
    const resultArray = ary.map(value => {
       return target.indexOf(value) > -1;
    });

    return resultArray.indexOf(false) === -1;
  };

  IndexedDb.dexie.nippo.orderBy('date').reverse().filter(_ => {
    return isContain(keywordArray, `${_.title} ${_.body}`);
  }).offset(offset).limit(limit).toArray().then((result) => {
    EventWorker.event.trigger('nippoList:done', result);
  }).catch(() => {
    EventWorker.event.trigger('nippoList:error');
  });
}

export function nippoGet(id) {
  if (id < 0) {
    EventWorker.event.trigger('nippoGet:done', demoNippore);
    return;
  }

  IndexedDb.dexie.nippo.get(id).then((result) => {
    EventWorker.event.trigger('nippoGet:done', result);
  }).catch((e) => {
    console.error(e);
    EventWorker.event.trigger('nippoGet:error');
  });
}

let input;
export function nippoImport() {
  loadFile().then(string => {
    JSON.parse(string);
    return string;
  }).then(jsonString => {
    return IndexedDb.import(jsonString);
  }).then(result => {
    if (result) {
      EventWorker.event.trigger('nippoImport:done');
    } else {
      EventWorker.event.trigger('nippoImport:error');
    }
  }).catch(e => {
    EventWorker.event.trigger('nippoImport:error');
  });
}

function loadFile() {
  return new Promise(resolve => {
    if(!input) {
      input = document.createElement("input");
      document.body.appendChild(input);
      input.style.display = 'none';
      input.type = 'file';
      input.addEventListener('change', event => {
        const file = event.target.files;
        const reader = new FileReader();
        reader.readAsText(file[0]);
        reader.onload = () => {
          resolve(reader.result);
        };
        document.body.removeChild(input);
      }, false);
    }
    input.click();
  })
}

export function nippoExport() {
  IndexedDb.export().then(jsonString => {
    if(jsonString === null) {
      return EventWorker.event.trigger('nippoExport:error');
    }

    const blob = new Blob([ jsonString ], { 'type' : 'text/plain' });
    const filename = 'nippore.json';

    if (window.navigator.msSaveBlob) {
      window.navigator.msSaveBlob(blob, filename);
    } else {
      const objectURL = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      document.body.appendChild(link);
      link.href = objectURL;
      link.download = filename;
      link.click();
      document.body.removeChild(link);
    }
  });
}

export function nippoDelete(id) {
  IndexedDb.dexie.nippo.delete(id).then((result) => {
    EventWorker.event.trigger('nippoDelete:done', result);
  }).catch((e) => {
    console.error(e);
    EventWorker.event.trigger('nippoDelete:error');
  });
}

export function nippoCount() {
  IndexedDb.dexie.nippo.count().then((count) => {
    EventWorker.event.trigger('nippoCount:done', count || 0);
  }).catch((e) => {
    EventWorker.event.trigger('nippoCount:error');
  });
}
