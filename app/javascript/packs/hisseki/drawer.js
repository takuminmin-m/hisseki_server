var numbers=0;
var neo1 = 0;
var board;
var context;

const Banner = {
  bgcolor: "#FFFFFF",  // 背景色
  font: "48px serif",  // フォント
  fontcolor: "blue",   // 文字色

  canvas: {
    width: null,   // 横幅
    height: null,  // 高さ
    ctx: null      // context
  }
}

// 記入されているかを確認
let empty_flag = true;

  window.onload = ()=>{
    enable_submit_button();

    document.getElementById("btn-extinction").onclick = function() {
      function clear() {
        empty_flag = true;
        context.clearRect(0, 0, board.width, board.height);
      }
      clear();
    }
   board = document.querySelector("#board");
   context = board.getContext('2d');

  // 直前のマウスのcanvas上のx座標とy座標を記録する
  const lastPosition = { x: null, y: null };

  // マウスがドラッグされているか(クリックされたままか)判断するためのフラグ
  let isDrag = false;

 Banner.canvas.ctx    = board.getContext("2d");
 Banner.canvas.width  = board.width;   // 横幅
 Banner.canvas.height = board.height;  // 高さ
  function draw(x, y) {
    // マウスがドラッグされていなかったら処理を中断する。
    // ドラッグしながらしか絵を書くことが出来ない。
    if(!isDrag) {
      return;
    }
    context.lineCap = 'round'; // 丸みを帯びた線にする
   context.lineJoin = 'round'; // 丸みを帯びた線にする
   context.lineWidth = 5; // 線の太さ
   context.strokeStyle = 'black'; // 線の色
   if (lastPosition.x === null || lastPosition.y === null) {
      // ドラッグ開始時の線の開始位置
      context.moveTo(x, y);
    } else {
      // ドラッグ中の線の開始位置
      context.moveTo(lastPosition.x, lastPosition.y);
    }
context.lineTo(x, y);

    // context.moveTo, context.lineToの値を元に実際に線を引く
    context.stroke();

    // 現在のマウス位置を記録して、次回線を書くときの開始点に使う
    lastPosition.x = x;
    lastPosition.y = y;
  }

    function dragStart(event) {
    // これから新しい線を書き始めることを宣言する
    // 一連の線を書く処理が終了したらdragEnd関数内のclosePathで終了を宣言する
    context.beginPath();

    empty_flag = false;

    isDrag = true;
  }

  function dragEnd(event) {
    // 線を書く処理の終了を宣言する
    context.closePath();
    isDrag = false;

    // 描画中に記録していた値をリセットする
    lastPosition.x = null;
    lastPosition.y = null;
  }

  function initEventHandler() {

      board.addEventListener('mousedown', dragStart);
      board.addEventListener('mouseup', dragEnd);
      board.addEventListener('mouseout', dragEnd);
      board.addEventListener('mousemove', (event) => {
        // eventの中の値を見たい場合は以下のようにconsole.log(event)で、
        // デベロッパーツールのコンソールに出力させると良い
        // console.log(event);

        draw(event.layerX, event.layerY);
      });
    }

    function pos(e) {
      var x, y;
      x = e.clientX - board.getBoundingClientRect().left;
      y = e.clientY - board.getBoundingClientRect().top;
      return [x, y];
    }

    function touch(canvas){
console.log("touch");
      canvas.addEventListener('touchstart', function(e) {
        dragStart();
      }, false);
      canvas.addEventListener('touchmove', function(e) {
        e.preventDefault();
        const x = pos(e.changedTouches[0])[0];
        const y = pos(e.changedTouches[0])[1];
        draw(x, y);
      }, false);
      canvas.addEventListener('touchend', function(e) {
        dragEnd();
      }, false);
    }

    touch(board);

    // イベント処理を初期化する
    initEventHandler();
  };

  function drawCanvas(){
    ctx    = Banner.canvas.ctx;
    width  = Banner.canvas.width;
    height = Banner.canvas.height;


    // 背景を指定色で塗りつぶす
    ctx.fillStyle = Banner.bgcolor;
    ctx.fillRect(0, 0, width, height);

    // 文字を描画
    ctx.font = Banner.font;
    ctx.fillStyle = Banner.fontcolor;
    ctx.fillText(Banner.text, 10, 90, width);
  };


document.onkeydown = function(){
  function clear() {
    empty_flag = true;
      context.clearRect(0, 0, board.width, board.height);
    }
 console.log (event.keyCode)
 numbers =(event.keyCode);
 if (numbers==13) {
     clear();
 }
};

// 送信ボタンの有効化関数 window.onloadに入れる
const enable_submit_button = () => {
  document.querySelector("#hisseki_form").addEventListener("submit", (e)=>{
    e.preventDefault();

    if (empty_flag) {
      alert("文字を入力されていません");
      location.reload();
      return;
    }

    const form = new FormData(document.querySelector("#hisseki_form"))
    const png_data_uri = board.toDataURL();
    form.append("image_data_uri", png_data_uri);

    const data = {
      method: "POST",
      body: form
    };

    fetch(url4send, data)
    .then(response => response.json())
    .then(data => {
      if (data["message"]) {
        alert(data["message"]);
      }
      if (data["url"]) {
        location.href = data["url"];
      }
    });
  });
};
