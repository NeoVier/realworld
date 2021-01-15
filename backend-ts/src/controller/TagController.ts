import { NextFunction, Request, Response } from "express";
import { getRepository } from "typeorm";
import Tag from "../entity/Tag";

class TagController {
  private tagRepository = getRepository(Tag);

  async all(_request: Request, _response: Response, _next: NextFunction) {
    return {
      tags: this.tagRepository
        .find()
        .then((tags) => tags.map((tag) => tag.tag)),
    };
  }
}

export default TagController;
