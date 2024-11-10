<script>
  import { onMount } from 'svelte';

  import nboardImage from '$assets/nboard.webp?url';

  import pins from '$lib/pins';

  export let tab;
  export let focus;
  let running = false;

  let context = {
    pins: Array.from({ length: 256 }, () => 0),
    anain: Array.from({ length: 8 }, () => 0),
    anaout: 0,
    jog: 0,
    cod: 0,
    lcd: Array.from({ length: 32 }, () => ' '),
    bargraph: Array.from({ length: 10 }, () => 0)
  };

  const jog = new Uint8Array(1);
  const cod = new Int8Array(1);

  const keyState = {
    // BUTTON 0
    "0": (state) => setPin(pins.PA_9, state),
    "À": (state) => setPin(pins.PA_9, state),

    // BUTTON 1
    "1": (state) => setPin(pins.PA_10, state),
    "&": (state) => setPin(pins.PA_10, state),

    // BUTTON 2
    "2": (state) => setPin(pins.PB_0, state),
    "É": (state) => setPin(pins.PB_0, state),

    // BUTTON 3
    "3":  (state) => setPin(pins.PB_7, state),
    "\"": (state) => setPin(pins.PB_7, state),
    
    // JOYSTICK DOWN
    "ARROWDOWN": (state) => state ? jog[0] |= 1 : jog[0] ^= 1,
    "S":         (state) => state ? jog[0] |= 1 : jog[0] ^= 1,

    // JOYSTICK UP
    "ARROWUP": (state) => state ? jog[0] |= 1 << 3 : jog[0] ^= 1 << 3,
    "Z":       (state) => state ? jog[0] |= 1 << 3 : jog[0] ^= 1 << 3,
    
    // JOYSTICK RIGHT
    "ARROWRIGHT": (state) => state ? jog[0] |= 1 << 4 : jog[0] ^= 1 << 4,
    "D":          (state) => state ? jog[0] |= 1 << 4 : jog[0] ^= 1 << 4,
    
    // JOYSTICK LEFT
    "ARROWLEFT": (state) => state ? jog[0] |= 1 << 1 : jog[0] ^= 1 << 1,
    "Q":         (state) => state ? jog[0] |= 1 << 1 : jog[0] ^= 1 << 1,

    // JOYSTICK MIDDLE
    " ": (state) => state ? jog[0] |= 1 << 2 : jog[0] ^= 1 << 2,
    "CLEAR": (state) => state ? jog[0] |= 1 << 2 : jog[0] ^= 1 << 2,

    // INCREMENT ENCODER
    "+": (state) => state && cod[0]++,
    // DECREMENT ENCODER
    "-": (state) => state && cod[0]--,
  };

  async function sendKey(key, state){
    if(!focus || !running) return;
    keyState[key.toUpperCase()]?.(state);
  }

  onMount(() => {
    document.addEventListener("keydown", ({ key, ctrlKey }) => (!ctrlKey && sendKey(key, 1)));
    document.addEventListener("keyup", ({ key, ctrlKey }) => (!ctrlKey && sendKey(key, 0)));
  });

  function inputSetAnain(e){
    setAnain(7, Number(e.target.value));
  }

  function inputReset(){
    resetNboard();
  }

  window.receiveContext = function receiveContext(data){
    const buffer = new DataView(new Uint8Array(data).buffer);

    let position = 0;

    for(let i in context.pins){
      context.pins[i] = buffer.getUint8(position++);
    }

    for(let i in context.anain){
      context.anain[i] = buffer.getFloat32(position);
      position += 4;
    }

    context.anaout = buffer.getFloat32(position);
    position += 4;

    context.jog = buffer.getUint8(position++);
    context.cod = buffer.getInt8(position++);

    for(let i in context.lcd){
      context.lcd[i] = String.fromCharCode(buffer.getUint8(position++));
    }

    for(let i in context.bargraph){
      context.bargraph[i] = buffer.getUint8(position++);
    }
  }

  let img;
  let width = 0;
  let height = 0;
  let x = 0;
  let y = 0;

  requestAnimationFrame(async function requestUpdate(){
    if(img){
      var doRatio = img.naturalWidth / img.naturalHeight;
      var cRatio = img.width / img.height;
      width = 0;
      height = 0;

      if (doRatio > cRatio) {
          width = img.width;
          height = width / doRatio;
      } else {
          height = img.height;
          width = height * doRatio;
      }

      x = (img.width - width) / 2;
      y = (img.height - height) / 2;
    }

    const run = await isRunning() != 0;

    if(run && !running)
      tab.set('nboard');

    running = run;

    if(focus)
      updateContext(jog[0], cod[0]);
    
    requestAnimationFrame(requestUpdate);
  });
</script>

<div class="nboard">
  <img bind:this={img} class="nimg" src={nboardImage} alt="nboard" />
  <div class="contents" style="width: {width}px; height: {height}px; left: {x}px; top: {y}px">
    <div class="leds">
      <div class="led" class:active={context.pins[pins.PA_2]} /> <!-- LED 0 -->
      <div class="led" class:active={context.pins[pins.PA_0]} /> <!-- LED 1 -->
      <div class="led" class:active={context.pins[pins.PA_1]} /> <!-- LED 2 -->
      <div class="led" class:active={context.pins[pins.PA_3]} /> <!-- LED 3 -->
      <div class="led" class:active={context.pins[pins.PA_5]} /> <!-- LED 4 -->
      <div class="led" class:active={context.pins[pins.PA_6]} /> <!-- LED 5 -->
      <div class="led" class:active={context.pins[pins.PA_7]} /> <!-- LED 6 -->
      <div class="led" class:active={context.pins[pins.PB_3]} /> <!-- LED 7 -->
    </div>
    <div class="lcd-backlight" class:active={running} />
    <div class="lcd">
      <div class="row">
        <div class="col">{context.lcd[0x00]}</div> <!-- LCD ROW 0 COL  0 -->
        <div class="col">{context.lcd[0x01]}</div> <!-- LCD ROW 0 COL  1 -->
        <div class="col">{context.lcd[0x02]}</div> <!-- LCD ROW 0 COL  2 -->
        <div class="col">{context.lcd[0x03]}</div> <!-- LCD ROW 0 COL  3 -->
        <div class="col">{context.lcd[0x04]}</div> <!-- LCD ROW 0 COL  4 -->
        <div class="col">{context.lcd[0x05]}</div> <!-- LCD ROW 0 COL  5 -->
        <div class="col">{context.lcd[0x06]}</div> <!-- LCD ROW 0 COL  6 -->
        <div class="col">{context.lcd[0x07]}</div> <!-- LCD ROW 0 COL  7 -->
        <div class="col">{context.lcd[0x08]}</div> <!-- LCD ROW 0 COL  8 -->
        <div class="col">{context.lcd[0x09]}</div> <!-- LCD ROW 0 COL  9 -->
        <div class="col">{context.lcd[0x0A]}</div> <!-- LCD ROW 0 COL 10 -->
        <div class="col">{context.lcd[0x0B]}</div> <!-- LCD ROW 0 COL 11 -->
        <div class="col">{context.lcd[0x0C]}</div> <!-- LCD ROW 0 COL 12 -->
        <div class="col">{context.lcd[0x0D]}</div> <!-- LCD ROW 0 COL 13 -->
        <div class="col">{context.lcd[0x0E]}</div> <!-- LCD ROW 0 COL 14 -->
        <div class="col">{context.lcd[0x0F]}</div> <!-- LCD ROW 0 COL 15 -->
      </div>
      <div class="row">
        <div class="col">{context.lcd[0x10]}</div> <!-- LCD ROW 1 COL  0 -->
        <div class="col">{context.lcd[0x11]}</div> <!-- LCD ROW 1 COL  1 -->
        <div class="col">{context.lcd[0x12]}</div> <!-- LCD ROW 1 COL  2 -->
        <div class="col">{context.lcd[0x13]}</div> <!-- LCD ROW 1 COL  3 -->
        <div class="col">{context.lcd[0x14]}</div> <!-- LCD ROW 1 COL  4 -->
        <div class="col">{context.lcd[0x15]}</div> <!-- LCD ROW 1 COL  5 -->
        <div class="col">{context.lcd[0x16]}</div> <!-- LCD ROW 1 COL  6 -->
        <div class="col">{context.lcd[0x17]}</div> <!-- LCD ROW 1 COL  7 -->
        <div class="col">{context.lcd[0x18]}</div> <!-- LCD ROW 1 COL  8 -->
        <div class="col">{context.lcd[0x19]}</div> <!-- LCD ROW 1 COL  9 -->
        <div class="col">{context.lcd[0x1A]}</div> <!-- LCD ROW 1 COL 10 -->
        <div class="col">{context.lcd[0x1B]}</div> <!-- LCD ROW 1 COL 11 -->
        <div class="col">{context.lcd[0x1C]}</div> <!-- LCD ROW 1 COL 12 -->
        <div class="col">{context.lcd[0x1D]}</div> <!-- LCD ROW 1 COL 13 -->
        <div class="col">{context.lcd[0x1E]}</div> <!-- LCD ROW 1 COL 14 -->
        <div class="col">{context.lcd[0x1F]}</div> <!-- LCD ROW 1 COL 15 -->
      </div>
    </div>
    <div class="bargraph">
      <div class="led" class:active={context.bargraph[9]} /> <!-- BARGRAPH LED 9 -->
      <div class="led" class:active={context.bargraph[8]} /> <!-- BARGRAPH LED 8 -->
      <div class="led" class:active={context.bargraph[7]} /> <!-- BARGRAPH LED 7 -->
      <div class="led" class:active={context.bargraph[6]} /> <!-- BARGRAPH LED 6 -->
      <div class="led" class:active={context.bargraph[5]} /> <!-- BARGRAPH LED 5 -->
      <div class="led" class:active={context.bargraph[4]} /> <!-- BARGRAPH LED 4 -->
      <div class="led" class:active={context.bargraph[3]} /> <!-- BARGRAPH LED 3 -->
      <div class="led" class:active={context.bargraph[2]} /> <!-- BARGRAPH LED 2 -->
      <div class="led" class:active={context.bargraph[1]} /> <!-- BARGRAPH LED 1 -->
      <div class="led" class:active={context.bargraph[0]} /> <!-- BARGRAPH LED 0 -->
    </div>
    <input type="range" value="0" min="0" max="1" step="any" on:input={inputSetAnain} />  <!-- POTENTIOMETER -->
    <div class="jog">
      <div class="btn up"     class:active={(context.jog >> 3) & 1} on:mousedown={() => keyState.ARROWUP(1)}    on:mouseup={() => keyState.ARROWUP(0)}    /> <!-- JOYSTICK UP     -->
      <div class="btn down"   class:active={(context.jog >> 0) & 1} on:mousedown={() => keyState.ARROWDOWN(1)}  on:mouseup={() => keyState.ARROWDOWN(0)}  /> <!-- JOYSTICK DOWN   -->
      <div class="btn left"   class:active={(context.jog >> 1) & 1} on:mousedown={() => keyState.ARROWLEFT(1)}  on:mouseup={() => keyState.ARROWLEFT(0)}  /> <!-- JOYSTICK LEFT   -->
      <div class="btn right"  class:active={(context.jog >> 4) & 1} on:mousedown={() => keyState.ARROWRIGHT(1)} on:mouseup={() => keyState.ARROWRIGHT(0)} /> <!-- JOYSTICK RIGHT  -->
      <div class="btn middle" class:active={(context.jog >> 2) & 1} on:mousedown={() => keyState.CONTROL(1)}    on:mouseup={() => keyState.CONTROL(0)}    /> <!-- JOYSTICK MIDDLE -->
    </div>
    <div class="bp bp0" class:active={context.pins[pins.PA_9 ]} on:mousedown={() => keyState["0"](1)} on:mouseup={() => keyState["0"](0)} /> <!-- BUTTON 0 -->
    <div class="bp bp1" class:active={context.pins[pins.PA_10]} on:mousedown={() => keyState["1"](1)} on:mouseup={() => keyState["1"](0)} /> <!-- BUTTON 1 -->
    <div class="bp bp2" class:active={context.pins[pins.PB_0 ]} on:mousedown={() => keyState["2"](1)} on:mouseup={() => keyState["2"](0)} /> <!-- BUTTON 2 -->
    <div class="bp bp3" class:active={context.pins[pins.PB_7 ]} on:mousedown={() => keyState["3"](1)} on:mouseup={() => keyState["3"](0)} /> <!-- BUTTON 3 -->
    <div class="cod">
      <input type="button" value="-" on:click={cod[0]--} /> <!-- DECREMENT ENCODER -->
      <input type="button" value="+" on:click={cod[0]++} /> <!-- INCREMENT ENCODER -->
    </div>
    <div class="reset" on:click={inputReset} /> <!-- RESET -->
  </div>
</div>

<style lang="scss">
  @font-face {
    font-family: 'Droid Sans Mono';
    font-style: normal;
    font-weight: 400;
    font-display: block;
    src: url("$assets/DroidSansMono.woff2") format('woff2');
    unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+2074, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
  }

  * {
    overflow: hidden;
    outline: none;
    border: none;

    user-select: none;
  }

  $margin: 20px;

  .nboard {
    position: absolute;
    top: calc($margin);
    left: calc($margin);
    width: calc(100% - $margin * 2);
    height: calc(100% - $margin * 2);

    .nimg {
      width: 100%;
      height: 100%;
      object-fit: contain;
      object-position: 50% 50%;

      image-rendering: -webkit-optimize-contrast;
    }

    .contents {
      position: absolute;
    }

    .leds {
      display: flex;
      justify-content: space-between;
      align-items: center;

      position: absolute;
      top: calc(68% - 1vh);
      left: calc(51.1% - 1vw);
      
      width: calc(27.4% + 2vw);
      height: calc(3.4% + 2vh);

      .led {
        width: 4.9%;
        height: calc(100% - 2vh);

        &.active {
          background-color: red;
          box-shadow: 0px 0px 5px 1px red;
        }

        &:first-child {
          margin-left: 1vw;
        }

        &:last-child {
          margin-right: 1vw;
        }
      }
    }

    .lcd-backlight {
      position: absolute;

      top: 8.4%;
      left: 40.6%;

      width: 54.2%;
      height: 17.7%;

      opacity: 0.3;

      border-top-left-radius: 2% 8%;
      border-top-right-radius: 4% 9%;

      display: none;

      background-color: hsl(30 60% 70%);

      &.active {
        display: block;
      }
    }

    .lcd {
      display: flex;
      position: absolute;

      flex-direction: column;
      justify-content: space-between;

      top: 9.5%;
      left: 42.5%;

      width: 50%;
      height: 15.5%;

      .row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        
        width: 100%;
        height: 50%;

        .col {
          font-family: 'Droid Sans Mono';
          text-align: center;
          font-size: 5vmin;
          font-weight: 600;

          width: 6%;

          color: #000;
        }
      }
    }

    .bargraph {
      display: flex;
      position: absolute;

      justify-content: space-between;

      top: 48.4%;
      left: 38.1%;

      width: 20.6%;
      height: 5.4%;

      .led {
        width: 7%;
        height: 100%;

        &.active {
          background-color: yellow;
        }
      }
    }
    
    input[type=range] {
      position: absolute;

      top: 83.6%;
      left: 16.7%;

      width: 16.5%;
      height: 5%;
    }

    .jog {
      position: absolute;
      
      top: 48%;
      left: 68.3%;

      width: 6.5%;
      height: 7.9%;
      
      .btn {
        position: absolute;

        width: 23%;
        height: 26%;

        cursor: pointer;

        &.active {
          background-color: green!important;
        }

        &:hover {
          background-color: rgb(0, 145, 0);
        }

        &.up {
          top: 1%;
          left: 40%;
        }

        &.down {
          top: 76%;
          left: 40%;
        }

        &.left {
          top: 38%;
          left: 5%;
        }

        &.right {
          top: 38%;
          left: 75%;
        }

        &.middle {
          top: 38%;
          left: 40%;
        }
      }
    }

    .bp {
      position: absolute;

      width: 3%;
      height: 3.8%;

      border-radius: 100%;

      cursor: pointer;

      &.active {
        background-color: green!important;
      }

      &:hover {
        background-color: rgb(0, 145, 0);
      }

      &.bp0 {
        top: 83.4%;
        left: 63.6%;
      }

      &.bp1 {
        top: 93.6%;
        left: 75.6%;
      }

      &.bp2 {
        top: 93.7%;
        left: 63.8%;
      }

      &.bp3 {
        top: 94%;
        left: 51.7%;
      }
    }

    .cod {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      position: absolute;
      
      top: 45%;
      left: 85%;

      width: 10%;
      height: 13.5%;
      
      input[type=button] {
        font-family: 'Droid Sans Mono';

        width: 45%;
        font-size: 5vmin;
        opacity: 0.5;
        cursor: pointer;

        transition: .2s opacity;

        &:hover {
          opacity: 0.7;
        }

        &:active {
          opacity: 0.8  ;
        }
      }
    }

    .reset {
      position: absolute;
      
      top: 29.8%;
      left: 8.8%;

      width: 2.6%;
      height: 3.4%;

      border-radius: 100%;

      cursor: pointer;

      background-color: transparent;

      transition: .1s background-color;

      &:hover {
        background-color: rgba(0, 128, 0, 0.5);
      }

      &:active {
        background-color: rgba(0, 128, 0, 0.6);
      }
    }
  }
</style>