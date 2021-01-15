import ArticleList from "components/articleList";
import Footer from "components/footer";
import { articles, popularTags } from "mockData";
import Head from "next/head";
import Link from "next/link";
import React from "react";
import Navbar from "../components/navbar";

export default function Home() {
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

              <ArticleList articles={articles} />
            </div>

            <div className="col-md-3">
              <div className="sidebar">
                <p>Popular Tags</p>

                <div className="tag-list">
                  {popularTags.map((tag, idx) => (
                    <Link href="" key={idx}>
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
