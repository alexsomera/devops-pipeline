import React from "react";
import Anchor from "../Anchor/Anchor";

const Home = () => {
  return (
    <main className="container">
      <div className="row">
        <div className="col-12 text-center">

      <h1>Hot Wheels</h1>
      <p>Bem-vindo ao CRUD Hot Wheels</p>
      <img src="/home.png" alt="Hot Wheels" className="img-fluid mb-3" />
      <br />
      <Anchor href="/cars" className="btn btn-warning m-2">
        Ver carros
      </Anchor>
      <Anchor href="/add" className="btn btn-warning m-2">
        Adicionar carro
      </Anchor>
      <Anchor href="/about" className="btn btn-warning m-2">
        Sobre
      </Anchor>
      </div>
      </div>
    </main>
  );
};

export default Home;