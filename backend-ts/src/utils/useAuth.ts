import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import User from "src/entity/User";
import { Repository } from "typeorm";

export type ReturnUser = {
  email: string;
  token: string;
  username: string;
  bio: string;
  image: string | null;
};

export type AuthResult = {
  user?: ReturnUser;
  id?: number;
  errors?: {
    token: string[];
  };
};

export const isAuth = (authResult: AuthResult): boolean => {
  return !!authResult.user;
};

export const useAuth = async (
  request: Request,
  response: Response,
  userRepository: Repository<User>
) => {
  const tokenHeader = request.headers.authorization;

  if (!tokenHeader) {
    response.statusCode = 401;
    return {
      errors: {
        token: ["No token informed"],
      },
    };
  }
  const token = tokenHeader.split(" ")[1];

  const decodedJwt = jwt.decode(token);
  try {
    const userId = (decodedJwt as { _id: number })._id;

    const user = await userRepository.findOne(userId);

    if (!user) {
      response.statusCode = 422;
      return {
        errors: {
          token: ["Could not find user"],
        },
      };
    }

    return {
      user: {
        email: user.email,
        token,
        username: user.username,
        bio: user.bio,
        image: user.image,
      },
      id: userId,
    };
  } catch {
    response.statusCode = 422;
    return {
      errors: {
        token: ["Error validating user"],
      },
    };
  }
};
