import Footer from "components/footer";
import Link from "next/link";
import { useState } from "react";
import { validateEmail } from "utils/validateEmail";
import Navbar from "../components/navbar";

type FormInfo = {
  errors: string[];
  name: string;
  email: string;
  password: string;
};

const Register = () => {
  const [formInfo, setFormInfo] = useState<FormInfo>({
    errors: [],
    name: "",
    email: "",
    password: "",
  });

  const handleNameChange = (event: React.FormEvent<HTMLInputElement>) => {
    setFormInfo({ ...formInfo, name: event.currentTarget.value });
  };

  const handleEmailChange = (event: React.FormEvent<HTMLInputElement>) => {
    const newEmail = event.currentTarget.value;
    const invalidEmailError = "Please enter a valid email address";
    const newErrors = formInfo.errors.filter(
      (email) => email !== invalidEmailError
    );
    if (validateEmail(newEmail)) {
      setFormInfo({
        ...formInfo,
        email: newEmail,
        errors: newErrors,
      });
    } else {
      setFormInfo({
        ...formInfo,
        email: newEmail,
        errors: [...newErrors, invalidEmailError],
      });
    }
  };

  const handlePasswordChange = (event: React.FormEvent<HTMLInputElement>) => {
    setFormInfo({ ...formInfo, password: event.currentTarget.value });
  };

  const handleSubmit = (event: React.FormEvent<HTMLButtonElement>) => {
    console.log(formInfo);
    event.preventDefault();
  };

  return (
    <>
      <Navbar activePage="register" />

      <div className="auth-page">
        <div className="container page">
          <div className="row">
            <div className="col-md-6 offset-md-3 col-xs-12">
              <h1 className="text-xs-center">Sign up</h1>
              <p className="text-xs-center">
                <Link href="/login">
                  <a>Have an account?</a>
                </Link>
              </p>

              <ul className="error-messages">
                {formInfo.errors.map((error, idx) => (
                  <li key={idx}>{error}</li>
                ))}
              </ul>

              <form>
                <fieldset className="form-group">
                  <input
                    type="text"
                    className="form-control form-control-lg"
                    placeholder="Your Name"
                    onChange={handleNameChange}
                  />
                </fieldset>

                <fieldset className="form-group">
                  <input
                    type="text"
                    className="form-control form-control-lg"
                    placeholder="Email"
                    onChange={handleEmailChange}
                  />
                </fieldset>

                <fieldset className="form-group">
                  <input
                    type="password"
                    className="form-control form-control-lg"
                    placeholder="Password"
                    onChange={handlePasswordChange}
                  />
                </fieldset>

                <button
                  className="btn btn-lg btn-primary pull-xs-right"
                  onClick={handleSubmit}
                >
                  Sign up
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </>
  );
};

export default Register;
