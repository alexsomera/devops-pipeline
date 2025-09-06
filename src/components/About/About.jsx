import React from "react";

export default function About() {
    return (
        <main className="container">
            <div className="row">
                <div className="col-12 text-center">
                    <h1>Sobre o Projeto</h1>
                    <img src="/about.jpg" alt="Carrinho Hot Wheels" className="img-fluid mb-3" />
                    
                    <div className="text-start mt-4">
                        <h3>🚗 Aplicação Hot Wheels CRUD</h3>
                        <p>Este é um sistema de gerenciamento de coleção de carrinhos Hot Wheels que permite:</p>
                        <ul>
                            <li>Adicionar novos carrinhos à coleção</li>
                            <li>Visualizar todos os carros cadastrados</li>
                            <li>Editar informações dos carrinhos</li>
                            <li>Excluir carros da coleção</li>
                        </ul>

                        <h3>⚛️ Tecnologias Utilizadas</h3>
                        <div className="row">
                            <div className="col-md-6">
                                <h5>React 18.3.1</h5>
                                <p><strong>O que é:</strong> Biblioteca JavaScript para construção de interfaces de usuário</p>
                                <p><strong>Função:</strong> Cria os componentes da aplicação (botões, formulários, páginas)</p>
                            </div>
                            <div className="col-md-6">
                                <h5>Vite 7.1.4</h5>
                                <p><strong>O que é:</strong> Ferramenta de build e servidor de desenvolvimento</p>
                                <p><strong>Função:</strong> Compila e empacota o código React para o navegador</p>
                            </div>
                        </div>

                        <div className="row mt-3">
                            <div className="col-md-6">
                                <h5>Bootstrap 5.3.3</h5>
                                <p><strong>O que é:</strong> Framework CSS</p>
                                <p><strong>Função:</strong> Fornece estilos e componentes visuais responsivos</p>
                            </div>
                            <div className="col-md-6">
                                <h5>Vitest</h5>
                                <p><strong>O que é:</strong> Framework de testes</p>
                                <p><strong>Função:</strong> Executa testes automatizados do código</p>
                            </div>
                        </div>

                        <div className="alert alert-info mt-4">
                            <h5>🤔 React vs Vite - Qual a diferença?</h5>
                            <p><strong>React:</strong> É a linguagem que escreve a aplicação (como os componentes funcionam)</p>
                            <p><strong>Vite:</strong> É a ferramenta que prepara o código React para rodar no navegador</p>
                            <p><em>Analogia:</em> Se React fosse um livro, Vite seria a editora que formata e publica o livro.</p>
                        </div>

                        <h3>🔧 Migração Tecnológica</h3>
                        <p>Este projeto foi <strong>migrado</strong> do Create React App para Vite para:</p>
                        <ul>
                            <li>✅ <strong>Resolver vulnerabilidades de segurança</strong> (29 → 0 vulnerabilidades)</li>
                            <li>⚡ <strong>Melhorar performance</strong> (build 10x mais rápido)</li>
                            <li>🔄 <strong>Hot reload instantâneo</strong> durante desenvolvimento</li>
                            <li>📦 <strong>Ferramentas mais modernas</strong> e atualizadas</li>
                        </ul>

                        <div className="mt-4">
                            <small className="text-muted">
                                Desenvolvido por Alex Fernando Somera<br/>
                                Disciplina: Desenvolvimento de Sistemas Frontend<br/>
                                Tecnologia: React + Vite + Bootstrap
                            </small>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    );
}
