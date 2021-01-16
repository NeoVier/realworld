import emailValidator from "email-validator";

export type ValidationError = {
  errors: {
    body?: string[];
    email?: string[];
    username?: string[];
    password?: string[];
    token?: string[];
  };
};

export type ValidationResult = "ok" | ValidationError;

export const chainResults = (results: ValidationResult[]): ValidationResult => {
  const tryAppend = (
    accList: string[] | undefined,
    resultList: string[] | undefined
  ): string[] | undefined => {
    if (accList && resultList) {
      return [...accList, ...resultList];
    } else if (!accList) {
      return resultList;
    }
    return accList;
  };

  return results.reduce((acc, result) => {
    if (acc === "ok") {
      if (result === "ok") return "ok";
      return result;
    }

    if (result === "ok") {
      return acc;
    }

    acc.errors.body = tryAppend(acc.errors.body, result.errors.body);
    acc.errors.email = tryAppend(acc.errors.email, result.errors.email);
    acc.errors.username = tryAppend(
      acc.errors.username,
      result.errors.username
    );
    acc.errors.password = tryAppend(
      acc.errors.password,
      result.errors.password
    );

    return acc;
  });
};

export const validateEmail = (
  email: string,
  takenEmails: string[]
): ValidationResult => {
  if (email.length === 0) {
    return { errors: { email: ["email can't be empty"] } };
  }

  if (takenEmails.includes(email)) {
    return { errors: { email: ["email already taken"] } };
  }

  return emailValidator.validate(email)
    ? "ok"
    : { errors: { email: ["enter a valid email"] } };
};

export const validateUsername = (
  username: string,
  takenUsernames: string[]
): ValidationResult => {
  if (username.length < 3) {
    return {
      errors: { username: ["username must have at least 3 characters"] },
    };
  }

  if (takenUsernames.includes(username)) {
    return {
      errors: { username: ["username already taken"] },
    };
  }

  return "ok";
};

export const validatePassword = (password: string): ValidationResult => {
  if (password.length < 3) {
    return {
      errors: { password: ["password must have at least 3 characters"] },
    };
  }

  return "ok";
};
