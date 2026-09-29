import { useEffect } from "react";

//Componente para controle do Tempo da Aplicação de Manutenções 
function ManutencaoTimer(intervaloSegundos, setIntervaloSegundos, isActive){
    useEffect(()=>{
        if(!isActive) return undefined; // se não estiver em manutenção o tempo não será definido

        //1. função 
        // se estiver em manutenção isActive === true
        const timerId = setInterval(()=>{ // função nativa do JS para determianr um tempo entre alguma coisa
            setIntervaloSegundos((previousSegundos) => previousSegundos +1);
        }, 1000);

        //2. Limpeza (opcional)
        return () => clearInterval(timerId);
    }, [isActive, setIntervaloSegundos]);

    //3. Array de Dependencias
    const horas = String(Math.floor(intervaloSegundos / 3600)).padStart(2, "0");
    const minutos = String(Math.floor((intervaloSegundos % 3600) / 60)).padStart(2, "0");
    const segundos = String(intervaloSegundos % 60).padStart(2, "0");

    return ( //display de tempo de manutenção de uma ordem
        <div className="timer-display" role="timer" aria-label="Tempo de execução da ordem">
            <span className="digits">{horas}:{minutos}:{segundos}</span>
        </div>
    );
}

export default ManutencaoTimer;