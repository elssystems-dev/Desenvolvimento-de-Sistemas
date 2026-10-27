//serviço de conexão com o mongoDB

import mongoose from "mongoose";

const DATABASE_URL = process.env.DATABASE_URL; //importei a url conexão

//vou verificar se existe uym endereço 
if(!DATABASE_URL) {
    throw new Error("Defina a variável DATABASE_URL no .env.local");
}

//Verificar se já existe uma conexão aberta
let cached = (global as any).mongoose;

if(!cached) {
    cached = (global as any).mongoose = {conn: null, promise:null};
}

//Conectar o MongoDB reutilizando uma conexão existente caso ja tenha
async function connectMongo(){
    if(cached.conn) {
        return cached.conn
    }

    if(!cached.promise){
        const opts = {bufferCommands: false};
        cached.promise = mongoose.connect(DATABASE_URL!, opts).then((inst)=>inst);
    }

    try {
        cached.conn = await cached.promise;
    } catch (error) {
        cached.promise = null;
        throw error;
    }

    return cached.conn;
}

export default connectMongo;