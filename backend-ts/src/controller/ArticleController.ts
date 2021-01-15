import { NextFunction, Request, Response } from "express";
import { getRepository } from "typeorm";
import Article from "../entity/Article";

class ArticleController {
  private articleRepository = getRepository(Article);

  async one(request: Request, _response: Response, _next: NextFunction) {
    return this.articleRepository.findOne({
      where: { slug: request.params.slug },
    });
  }
}

export default ArticleController;
