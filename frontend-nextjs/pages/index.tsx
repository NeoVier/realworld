import Footer from "components/footer";
import Head from "next/head";
import Link from "next/link";
import React from "react";
import Article from "types/Article";
import Navbar from "../components/navbar";

export default function Home() {
  const articles: Article[] = [
    {
      slug: "first-article",
      title: "First Title",
      description: "First description",
      body: "First body",
      tagList: ["First tag", "second tag"],
      createdAt: new Date(),
      updatedAt: new Date(),
      favorited: false,
      favoritesCount: 0,
      author: {
        username: "Henrique Buss",
        bio: "Functional programmer",
        image: "http://i.imgur.com/N4VcUeJ.jpg",
        following: false,
      },
    },
  ];

  const popularTags = [
    "programming",
    "javascript",
    "emberjs",
    "angularjs",
    "react",
    "mean",
    "node",
    "rails",
  ];

  return (
    <>
      <Head>
        <title>Home — Conduit</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Navbar activePage="home" />

      <div className="home-page">
        <div className="banner">
          <div className="container">
            <h1 className="logo-font">conduit</h1>
            <p>A place to share your knowledge.</p>
          </div>
        </div>

        <div className="container page">
          <div className="row">
            <div className="col-md-9">
              <div className="feed-toggle">
                <ul className="nav nav-pills outline-active">
                  <li className="nav-item">
                    <Link href="">
                      {/* TODO */}
                      <a className="nav-link disabled">Your Feed</a>
                    </Link>
                  </li>

                  <li className="nav-item">
                    <Link href="">
                      {/* TODO */}
                      <a className="nav-link active">Global Feed</a>
                    </Link>
                  </li>
                </ul>
              </div>

              {articles.map((article) => (
                <div className="article-preview">
                  <div className="article-meta">
                    <Link href="">
                      {/* TODO */}
                      <a>
                        <img src={article.author.image ?? ""} />
                      </a>
                    </Link>

                    <div className="info">
                      <Link href="">
                        {/* TODO */}
                        <a className="author">{article.author.username}</a>
                      </Link>
                      <span className="date">January 20th</span> {/* TODO */}
                    </div>

                    <button className="btn btn-outline-primary btn-sm pull-xs-right">
                      <i className="ion-heart"></i> {article.favoritesCount}
                    </button>
                  </div>

                  <Link href="">
                    {/* TODO */}
                    <a className="preview-link">
                      <h1>{article.title}</h1>
                      <p>{article.description}</p>
                      <span>Read more...</span>
                    </a>
                  </Link>
                </div>
              ))}
            </div>

            <div className="col-md-3">
              <div className="sidebar">
                <p>Popular Tags</p>

                <div className="tag-list">
                  {popularTags.map((tag) => (
                    <Link href="">
                      {/* TODO */}
                      <a className="tag-pill tag-default">{tag}</a>
                    </Link>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
}
