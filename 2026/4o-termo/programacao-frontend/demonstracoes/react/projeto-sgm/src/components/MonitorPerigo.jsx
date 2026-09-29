const { useState, useEffect } = require("react");

function MonitorPerigo(){
    const [contador, setContador] = useState(0);

    // function usando useEffect => ERRO Grave de loop infinito

    useEffect(()=>{
        console.log("Executando efeito sem array de depências...");
        setContador(contador + 1); //dispara  a re-renderização
    });

    return (
    <div>Contador: {contador}</div>
);
}

export default MonitorPerigo