import Head from "next/head";
import Link from "next/link";
import Page from "types/Page";
import User from "types/User";

type Props = {
  activePage: Page;
  user?: User;
};

type NavItem = {
  href: string;
  title: string;
  page: Page;
  icon?: string;
};

const Navbar = ({ activePage, user = undefined }: Props) => {
  const items: NavItem[] =
    user === undefined
      ? [
          { href: "/", title: "Home", page: "home" },
          { href: "", title: "Sign in", page: "login" },
          { href: "", title: "Sign up", page: "register" },
        ]
      : [
          { href: "/", title: "Home", page: "home" },
          {
            href: "",
            title: "New Article",
            page: "editor",
            icon: "ion-compose",
          },
          { href: "", title: "Settings", page: "settings", icon: "ion-gear-a" },
          { href: "", title: user.username, page: "profile" },
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
            {items.map((item) => (
              <li className="nav-item">
                <Link href={item.href}>
                  <a
                    className={`nav-link ${
                      activePage === item.page ? "active" : ""
                    }`}
                  >
                    {item.icon && <i className={item.icon} />}
                    {item.title}
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
