import React from "react";
import Anchor from "../Anchor/Anchor";
const links = [
  {
    id: 1,
    url: "/",
    text: "Home",
  },
  {
    id: 2,
    url: "/about",
    text: "Sobre",
  },
  {
    id: 3,
    url: "/cars",
    text: "Carros",
  },
  {
    id: 4,
    url: "/add",
    text: "Adicionar Carro",
  },
];


const NavBar = () => {
  return (
      <nav className="navbar navbar-dark navbar-expand-md">
        <Anchor className="navbar-brand" href="/">
        <img src="/logo.png" className="" alt="logo" width={180} height={68} />
        </Anchor>
        <button
          className="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarNav"
          aria-controls="navbarNav"
          aria-expanded="false"
          aria-label="Toggle navigation">
          <span className="navbar-toggler-icon"></span>
        </button>
        <div className="collapse navbar-collapse justify-content-end" id="navbarNav">
          <ul className="navbar-nav">
            {links.map((link) => {
              return (
                <li key={link.id} className="nav-item">
                  <Anchor className="nav-link" href={link.url}>
                    {link.text}
                  </Anchor>
                </li>
              );
            })}
          </ul>
        </div>
      </nav>
  );
};

export default NavBar;