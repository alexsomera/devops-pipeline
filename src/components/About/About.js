import React from "react";

export default function About() {
    return (
        <main className="container">
            <div className="row">
                <div className="col-12 text-center">
                    <h1>Sobre</h1>
                    <img src={process.env.PUBLIC_URL + 'about.jpg'} alt="Carrinho Hot Wheels" className="img-fluid mb-3" />
                    <p>Este é um CRUD de carrinhos Hot Wheels feito com React.</p>
                    <p>Este projeto permite registrar uma coleção de carrinhos Hot Wheels.</p>
                    <p>É possível adicionar, editar e excluir carros.</p>
                    <p>Desenvolvido por Alex Fernando Somera para a Fase 1 da disciplina Desenvolvimento de Sistemas frontend.</p>
                </div>
            </div>
        </main>
    );
}
