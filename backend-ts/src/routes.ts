import ArticleController from "./controller/ArticleController";
import TagController from "./controller/TagController";
import UserController from "./controller/UserController";

export const Routes = [
  // {
  //   method: "get",
  //   route: "/users",
  //   controller: UserController,
  //   action: "all",
  // },
  // {
  //   method: "get",
  //   route: "/users/:id",
  //   controller: UserController,
  //   action: "one",
  // },
  // {
  //   method: "post",
  //   route: "/users",
  //   controller: UserController,
  //   action: "save",
  // },
  // {
  //   method: "delete",
  //   route: "/users/:id",
  //   controller: UserController,
  //   action: "remove",
  // },
  {
    method: "post",
    route: "/api/users",
    controller: UserController,
    action: "register",
  },

  {
    method: "get",
    route: "/api/articles/:slug",
    controller: ArticleController,
    action: "one",
  },

  {
    method: "get",
    route: "/api/tags",
    controller: TagController,
    action: "all",
  },
];
