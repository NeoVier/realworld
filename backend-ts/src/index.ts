import bodyParser from "body-parser";
import cors from "cors";
import express, { Request, Response } from "express";
import "reflect-metadata";
import { createConnection } from "typeorm";
import { Routes } from "./routes";

createConnection()
  .then(async (_connection) => {
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
    app.use(cors());

    // start express server
    app.listen(3000);

    // const user = connection.manager.create(User, {
    //   email: "henrique.buss@hotmail.com",
    //   username: "neovier",
    //   bio: "functional programming enthusiast",
    // });
    // connection.manager.save(user);

    // const article = {
    //   title: "My first article",
    //   description: "This is my first article",
    //   body: "Lorem ipsum",
    //   tagList: [],
    //   author: user,
    //   favorited: [],
    // };

    // await connection.manager.save(
    //   connection.manager.create(Article, article)
    // );

    console.log("Express server has started on port 3000.");
  })
  .catch((error) => console.log(error));
