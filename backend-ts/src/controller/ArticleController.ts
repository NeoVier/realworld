import { NextFunction, Request, Response } from "express";
import { getRepository } from "typeorm";
import Article from "../entity/Article";
import Tag from "../entity/Tag";
import User from "../entity/User";
import { useAuth } from "../utils/useAuth";

class ArticleController {
  private articleRepository = getRepository(Article);
  private authorRepository = getRepository(User);
  private tagRepository = getRepository(Tag);

  async one(request: Request, _response: Response, _next: NextFunction) {
    return this.articleRepository.findOne({
      where: { slug: request.params.slug },
    });
  }

  // async list(
  //   request: Request,
  //   _reponse: Response,
  //   _next: NextFunction
  // ): Promise<{ articles: Article[] }> {
  //   const tag = request.query.tag;
  //   console.log("tag:");
  //   console.log(tag);
  //   const authorUsername = request.query.author;
  //   const author = await this.authorRepository.findOne({
  //     where: { username: authorUsername },
  //   });
  //   console.log("author:");
  //   console.log(author);
  //   const favoritedBy = request.query.favorited;
  //   console.log("favoritedBy:");
  //   console.log(favoritedBy);
  //   const limit =
  //     typeof request.query.limit === "string"
  //       ? parseInt(request.query.limit)
  //       : 20;
  //   console.log("limit:");
  //   console.log(limit);
  //   const offset =
  //     typeof request.query.offset === "string"
  //       ? parseInt(request.query.offset)
  //       : 0;
  //   console.log("offset:");
  //   console.log(offset);

  //   const params: FindManyOptions<Article> = {
  //     where: {
  //       tagList: tag,
  //       // author: author,
  //       // favorited:
  //     },
  //     order: { updatedAt: "DESC" },
  //     skip: offset,
  //     take: limit,
  //     relations: ["author", "favorited", "tagList"],
  //   };
  //   console.log("params:");
  //   console.log(params);

  //   const articles = await this.articleRepository.find({
  //     where: {
  //       body: "Lorem ipsum",
  //       tagList: ["dragon"],
  //     },
  //     order: { updatedAt: "DESC" },
  //     skip: offset,
  //     take: limit,
  //   });
  //   this.articleRepository.findAndCount;
  //   console.log(articles);
  //   return { articles: articles };
  // }

  async create(request: Request, response: Response, _next: NextFunction) {
    const auth = await useAuth(request, response, this.authorRepository);
    if (!auth.user) {
      return { errors: auth.errors! };
    }

    const articleToCreate = request.body.article;

    if (!articleToCreate.title) {
      return { errors: { title: ["title cannot be empty"] } };
    }
    if (!articleToCreate.description) {
      return { errors: { description: ["description cannot be empty"] } };
    }
    if (!articleToCreate.body) {
      return { errors: { body: ["body cannot be empty"] } };
    }

    const tagList = await this.tagRepository.save(
      articleToCreate.tagList.map((tag: string) =>
        this.tagRepository.create({ tag: tag })
      )
    );

    const author = await this.authorRepository.findOne({
      where: {
        username: auth.user.username,
      },
    });
    if (!author) {
      response.statusCode = 403;
      return { errors: { username: ["username not found"] } };
    }
    const newArticle = await this.articleRepository.save(
      this.articleRepository.create({
        title: articleToCreate.title,
        description: articleToCreate.description,
        body: articleToCreate.body,
        author,
        tagList,
        favorited: [],
        favoritesCount: 0,
      })
    );

    return { article: newArticle };
  }
}

export default ArticleController;
