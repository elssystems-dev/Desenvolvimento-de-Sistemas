import { useState } from 'react'
import heroImg from './assets/hero.png'
import reactLogo from './assets/react.svg'
import viteLogo from './assets/vite.svg'
import './App.css'

function Header() {
  return (
    <header>
      <h1>TO-DO PRO</h1>
      <ProjectInfo></ProjectInfo>
    </header>
  );
}

function ProjectInfo() {
  const nome = "ELS Systems"
  return (
    <section>
      <h2>{nome} - Uma lista de afazeres <u>profissional</u></h2>
    </section>
  );
}

function TaskSummary() {
	const [tasks, setTasks] = useState([
		{ id: 1, title: "Estudar React", completed: false },
		{ id: 2, title: "Criar projeto Vite", completed: true },
    { id: 3, title: "Entender estados", completed: false}
	]);

  const [newTask, setNewTask] = useState("");

	const completedCount = tasks.filter((task) => task.completed).length;

	function toggleTask(taskId) {
		setTasks((currentTasks) =>
			currentTasks.map((task) =>
				task.id === taskId
					? { ...task, completed: !task.completed }
					: task
			)
		);
	}

  function addTask() {
    if (!newTask.trim()) return;
    setTasks((currentTasks) => [
      ...currentTasks,
      {id: Date.now(), title: newTask.trim(), completed: false}
    ]);
    setNewTask("");
  }

	return (
		<section className="tasks-display">
      <div className='new-task-form'>
        <input 
          type="text" 
          value={newTask} 
          placeholder='Nova tarefa...'
          onChange={(e) => setNewTask(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && addTask()}
        />
        <button className='action-btn add-task' onClick={addTask}>Nova tarefa</button>
      </div>
      <p className='concluded-tasks'>Concluídas: {completedCount}</p>
			<ul className='task-list'>
				{tasks.map((task) => (
					<li className='task-card' key={task.id}>
						<h3>{task.title}</h3>
						<button className={`action-btn task-btn ${task.completed ? 'task-completed' : 'task-incompleted'}`} type="button" onClick={() => toggleTask(task.id)}>
							{task.completed ? "Desconcluir" : "Concluir"}
						</button>
					</li>
				))}
			</ul>
		</section>
	);
}




function App() {
  const [count, setCount] = useState(5)

  return (
    <>
      <Header></Header>
      <TaskSummary></TaskSummary>
    </>
  )
}

export default App
