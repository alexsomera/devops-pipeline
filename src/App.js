
import React from "react";
import Header from './components/Header/Header';
import Footer from './components/Footer/Footer';
import Home from "./components/Home/Home";
import CarForm from "./components/CarForm/CarForm";
import CarsList from "./components/CarsList/CarsList";
import About from "./components/About/About";
import NotFound from "./components/NotFound/NotFound";

import "bootstrap/dist/css/bootstrap.min.css";
import "./App.css";

function App() {
  
  const componentes = {
    "/": <Home />,
    "/home": <Home />,
    "/about": <About />,
    "/add": <CarForm />,
    "/cars": <CarsList />,
    "/not-found": <NotFound />,
  };
  
  const url = window.location.pathname;

  return (
    <>
      <Header className="bg-primary" />
      {componentes[url] || componentes["/not-found"]}
      <Footer />
    </>
  );
}

export default App;