import Head from "next/head";
import React from "react";
import Navbar from "../components/Navbar";

export default function Home() {
  return (
    <>
      <Head>
        <title>Home — Conduit</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <Navbar />
    </>
  );
}
