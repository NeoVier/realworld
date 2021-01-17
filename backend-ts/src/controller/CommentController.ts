import { NextFunction, Request, Response } from "express";
import { getRepository } from "typeorm";
import Article from "../entity/Article";
import Comment from "../entity/Comment";
import User from "../entity/User";
import { useAuth } from "../utils/useAuth";

class CommentController {
  private articleRepository = getRepository(Article);
  private commentRepository = getRepository(Comment);
  private userRepository = getRepository(User);

  async create(request: Request, response: Response, _next: NextFunction) {
    const auth = await useAuth(request, response, this.userRepository);

    if (!auth.user) {
      return { errors: auth.errors };
    }

    const body = (request.body.comment as any).body;
    const slug = request.params.slug;

    const author = await this.userRepository.findOne({
      where: {
        username: auth.user.username,
      },
    });

    if (!author) {
      return { errors: { username: ["username not found"] } };
    }

    const article = await this.articleRepository.findOne({
      where: {
        slug,
      },
    });

    if (!article) {
      return { errors: { slug: ["slug not found"] } };
    }

    const newComment = await this.commentRepository.save(
      this.commentRepository.create({
        article,
        author,
        body,
      })
    );

    return { comment: newComment };
  }

  async fromArticle(
    request: Request,
    _response: Response,
    _next: NextFunction
  ) {
    const slug = request.params.slug;

    if (!slug) {
      return { errors: { slug: ["slug not found"] } };
    }

    const article = await this.articleRepository.findOne({
      where: {
        slug,
      },
    });

    if (!article) {
      return { errors: { slug: ["slug not found"] } };
    }

    const comments = await this.commentRepository.find({
      where: {
        article,
      },
      relations: ["author"],
    });

    return { comments: comments };
  }
}

export default CommentController;
