import Link from "next/link";
import React from "react";
import Article from "types/Article";
import AuthorImage from "./authorImage";

type Variant = "small" | "large";
type Props = { article: Article; variant?: Variant };

const ArticleMeta = ({ article, variant = "large" }: Props) => {
  switch (variant) {
    case "large":
      return (
        <div className="article-meta">
          <AuthorImage author={article.author} variant="clickable" />
          <div className="info">
            <Link href={`/profile/${article.author.username}`}>
              <a className="author">{article.author.username}</a>
            </Link>
            <span className="date">January 20th</span>
          </div>
          <button className="btn btn-sm btn-outline-secondary">
            <i className="ion-plus-round"></i>
            &nbsp; Follow {article.author.username}
            <span className="counter">(10)</span> {/* TODO */}
          </button>{" "}
          <button className="btn btn-sm btn-outline-primary">
            <i className="ion-heart"> </i>
            &nbsp; Favorite Post{" "}
            <span className="counter">({article.favoritesCount})</span>
          </button>
        </div>
      );

    case "small":
      return (
        <div className="article-meta">
          <AuthorImage author={article.author} variant="clickable" />

          <div className="info">
            <Link href={`/profile/${article.author.username}`}>
              <a className="author">{article.author.username}</a>
            </Link>
            <span className="date">January 20th</span> {/* TODO */}
          </div>

          <button className="btn btn-outline-primary btn-sm pull-xs-right">
            <i className="ion-heart"></i> {article.favoritesCount}
          </button>
        </div>
      );
  }
};

export default ArticleMeta;
