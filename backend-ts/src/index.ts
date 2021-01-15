import bodyParser from "body-parser";
import express, { Request, Response } from "express";
import "reflect-metadata";
import { createConnection } from "typeorm";
import Article from "./entity/Article";
import User from "./entity/User";
import { Routes } from "./routes";

createConnection()
  .then(async (connection) => {
    // create express app
    const app = express();
    app.use(bodyParser.json());

    // register express routes from defined application routes
    Routes.forEach((route) => {
      (app as any)[route.method](
        route.route,
        (req: Request, res: Response, next: Function) => {
          const result = new (route.controller as any)()[route.action](
            req,
            res,
            next
          );
          if (result instanceof Promise) {
            result.then((result) =>
              result !== null && result !== undefined
                ? res.send(result)
                : undefined
            );
          } else if (result !== null && result !== undefined) {
            res.json(result);
          }
        }
      );
    });

    // setup express app here
    // ...

    // start express server
    app.listen(3000);

    const user = connection.manager.create(User, {
      email: "henrique.buss@hotmail.com",
      username: "neovier",
      bio: "functional programming enthusiast",
    });
    connection.manager.save(user);

    const article = {
      author: user,
      body: "Lorem ipsum",
      description: "This is my first article",
      title: "My first article",
    };

    // insert new users for test
    await connection.manager.save(
      // connection.manager.create(User, {
      //   email: "henrique.buss@hotmail.com",
      //   username: "neovier",
      //   bio: "functional programming enthusiast",
      //   articles: [],
      //   favorited: [],
      //   followedBy: [],
      //   follows: [],
      //   comments: [],
      // })
      connection.manager.create(Article, article)
      //   connection.manager.create(User, {
      //     firstName: "Timber",
      //     lastName: "Saw",
      //     age: 27,
      //   })
      // );
      // await connection.manager.save(
      //   connection.manager.create(User, {
      //     firstName: "Phantom",
      //     lastName: "Assassin",
      //     age: 24,
      //   })
    );

    console.log("Express server has started on port 3000.");
  })
  .catch((error) => console.log(error));
