import { NextFunction, Request, Response } from "express";
import { FindConditions, getRepository } from "typeorm";
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

  async list(
    request: Request,
    _reponse: Response,
    _next: NextFunction
  ): Promise<{ articles: Article[]; articlesCount: number }> {
    let filters: FindConditions<Article> = {};
    // TODO - Filter by tag
    // const tagName = request.query.tag;
    // const tag = await this.tagRepository.findOne({
    //   where: { tag: tagName },
    // });
    // const tags = await this.tagRepository.find();
    // console.log(tags);

    const authorUsername = request.query.author;
    const author = await this.authorRepository.findOne({
      where: { username: authorUsername },
    });
    if (author) {
      filters = { ...filters, author };
    }

    // TODO - Filter by favorited
    // const favoritedByUsername = request.query.favorited;
    // const favoritedBy = await this.authorRepository.findOne({
    //   where: {
    //     username: favoritedByUsername,
    //   },
    // });

    const limit =
      typeof request.query.limit === "string"
        ? parseInt(request.query.limit)
        : 20;

    const offset =
      typeof request.query.offset === "string"
        ? parseInt(request.query.offset)
        : 0;

    const articles = await this.articleRepository.find({
      order: { updatedAt: "DESC" },
      skip: offset,
      take: limit,
      relations: ["tagList", "author", "favorited"],
    });

    return { articles: articles, articlesCount: articles.length };
  }

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

  async update(request: Request, response: Response, _next: NextFunction) {
    const auth = await useAuth(request, response, this.authorRepository);
    const slugToUpdate = request.params.slug;

    if (!auth.user) {
      return { errors: auth.errors! };
    }

    const articleToUpdate = await this.articleRepository.findOne({
      where: { slug: slugToUpdate },
    });

    if (!articleToUpdate) {
      return { errors: { slug: ["slug not found"] } };
    }

    const newArticleFields = request.body.article;
    const newTitle = newArticleFields.title;
    const newDescription = newArticleFields.description;
    const newBody = newArticleFields.body;

    const newArticle = await this.articleRepository.save({
      ...articleToUpdate,
      title: newTitle ? newTitle : articleToUpdate.title,
      description: newDescription
        ? newDescription
        : articleToUpdate.description,
      body: newBody ? newBody : articleToUpdate.body,
    });

    return { article: newArticle };
  }

  async delete(request: Request, response: Response, _next: NextFunction) {
    const auth = await useAuth(request, response, this.authorRepository);
    const slugToDelete = request.params.slug;
    if (!auth.user) {
      return { errors: auth.errors };
    }

    await this.articleRepository.delete({ slug: slugToDelete });
    return { status: "ok" };
  }
}

export default ArticleController;
