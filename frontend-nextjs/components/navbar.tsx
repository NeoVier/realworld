import Head from "next/head";
import Link from "next/link";
import Page from "types/Page";

type Props = {
  activePage: Page;
};

type NavItem = {
  href: string;
  title: string;
  page: Page;
};

const Navbar = ({ activePage }: Props) => {
  const items = [
    { href: "/", title: "Home", page: "home" },
    { href: "", title: "Sign in", page: "login" },
    { href: "", title: "Sign up", page: "register" },
  ];
  return (
    <>
      <Head>
        <meta charSet="utf-8" />
        {/* <!-- Import Ionicon icons & Google Fonts our Bootstrap theme relies on --> */}
        <link
          href="//code.ionicframework.com/ionicons/2.0.1/css/ionicons.min.css"
          rel="stylesheet"
          type="text/css"
        />
        <link
          href="//fonts.googleapis.com/css?family=Titillium+Web:700|Source+Serif+Pro:400,700|Merriweather+Sans:400,700|Source+Sans+Pro:400,300,600,700,300italic,400italic,600italic,700italic"
          rel="stylesheet"
          type="text/css"
        />
        {/* <!-- Import the custom Bootstrap 4 theme from our hosted CDN --> */}
        <link rel="stylesheet" href="//demo.productionready.io/main.css"></link>
      </Head>
      <nav className="navbar navbar-light">
        <div className="container">
          <Link href="/">
            <a className="navbar-brand">conduit</a>
          </Link>

          <ul className="nav navbar-nav pull-xs-right">
            {items.map(({ href, title, page }) => (
              <li className="nav-item">
                <Link href={href}>
                  <a
                    className={`nav-link ${
                      activePage === page ? "active" : ""
                    }`}
                  >
                    {title}
                  </a>
                </Link>
              </li>
            ))}
          </ul>
        </div>
      </nav>
    </>
  );
};

export default Navbar;
