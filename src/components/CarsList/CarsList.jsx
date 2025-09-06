import React, { useState } from "react";

import carsData from "../../carsData";
import Anchor from "../Anchor/Anchor";

if (!localStorage.getItem("cars")) {
    localStorage.setItem("cars", JSON.stringify(carsData));
}

const carros = JSON.parse(localStorage.getItem("cars"));

export default function CarsList() {

    const [cars, setCars] = useState([...carros]);



    function deleteCar(id) {
        setCars(cars.filter((car) => car.id !== id));
        localStorage.setItem("cars", JSON.stringify(cars.filter((car) => car.id !== id)));
    }

    function editCar(id) {
        const carEdit = cars.find((car) => car.id === id);
        
        console.log(carEdit);
        window.location.href = "/add?id=" + id;

    }

    return (
        <main className="container">
            <h1>Lista de Carros Hot Wheels</h1>
            <table className="table table-sm table-hover table-stripped">
                <thead>
                    <tr>
                        <th scope="col">Id</th>
                        <th scope="col">Marca</th>
                        <th scope="col">Modelo</th>
                        <th scope="col">Ano</th>
                        <th scope="col">Cor</th>
                        <th scope="col">Preço</th>
                        <th scope="col">Ações</th>
                    </tr>
                </thead>
                <tbody>
                    {cars.map((car) => (
                        <tr key={car.id}>
                            <td>{car.id}</td>
                            <td>{car.brand}</td>
                            <td>{car.model}</td>
                            <td>{car.year}</td>
                            <td>{car.color}</td>
                            <td>{car.price}</td>
                            <td>
                                <span className="link-action text-info" onClick={() => editCar(car.id)}>Editar</span>
                                <span className="link-action text-danger" onClick={() => deleteCar(car.id)}>Excluir</span>
                            </td>
                        </tr>
                    ))}
                </tbody>

            </table>

            <Anchor href="/add" className="btn btn-warning">
                Adicionar Carro
            </Anchor>

        </main>
    );
}

