import { Elm } from "./src/Main.elm";

const USER_TOKEN = "userToken";

const userToken = localStorage.getItem(USER_TOKEN);

const app = Elm.Main.init({
  node: document.getElementById("main"),
  flags: {
    dimmensions: { width: window.innerWidth, height: window.innerHeight },
    userToken,
  },
});

app.ports.sendUser.subscribe(function (user) {
  console.log(user.token);
  localStorage.setItem(USER_TOKEN, user.token);
});
