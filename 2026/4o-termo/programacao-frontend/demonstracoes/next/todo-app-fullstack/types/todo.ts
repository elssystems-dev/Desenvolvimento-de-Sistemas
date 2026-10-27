// Interface representativa da estrutura
export interface ITodoItem {
    _id: string;
    title: string;
    completed: boolean;
    createAt: string;
}

// Elemento de criação para uma nova tarefa
export interface ICreateTodoDTO {
    title: string;
}

// Interface para modificar uma tarefa (pode modificar titulo ou status)
export interface IUpdateTodoDTO {
    title?: string;
    completed?: boolean
}