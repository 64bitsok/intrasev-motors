<?php

namespace App\Controllers;

use App\Models\UsuarioModel;
use CodeIgniter\Controller;

class AuthController extends BaseController
{
    public function index()
    {
        // Si ya está logueado, redirigir según su rol
        if (session()->has('id_usuario')) {
            if (session()->get('id_rol') == 1) {
                return redirect()->to(site_url('admin/dashboard'));
            } else {
                return redirect()->to(site_url('/'));
            }
        }
        
        return view('login');
    }

    public function login()
    {
        $usuarioModel = new UsuarioModel();

        $usuario = $this->request->getPost('usuario');
        $password = $this->request->getPost('password');

        // Buscar el usuario por su nombre de usuario
        $user = $usuarioModel->where('usuario', $usuario)->first();

        // Verificamos si existe el usuario y si la contraseña (texto plano según SQL provisto) coincide
        if ($user && $user['contrasena_hash'] === $password) {
            
            // Establecer variables de sesión
            $sessionData = [
                'id_usuario' => $user['id_usuario'],
                'usuario' => $user['usuario'],
                'nombre_completo' => $user['nombre_completo'],
                'id_rol' => $user['id_rol'],
                'isLoggedIn' => true
            ];
            
            session()->set($sessionData);

            // Bifurcación según el id_rol
            if ($user['id_rol'] == 1) {
                // Administrador
                return redirect()->to(site_url('admin/dashboard'));
            } else {
                // Cliente
                return redirect()->to(site_url('/'));
            }
        } else {
            // Error en credenciales
            session()->setFlashdata('error', 'Usuario o contraseña incorrectos.');
            return redirect()->to(site_url('login'));
        }
    }

    public function registro()
    {
        return view('registro');
    }

    public function registrar()
    {
        $usuarioModel = new UsuarioModel();

        // Validar si el usuario o correo ya existen (opcional pero recomendado)
        $usuarioExistente = $usuarioModel->where('usuario', $this->request->getPost('usuario'))->first();
        if ($usuarioExistente) {
            session()->setFlashdata('error', 'El nombre de usuario ya está en uso. Por favor, elige otro.');
            return redirect()->to(site_url('registro'));
        }

        $data = [
            'id_rol'             => 2, // Rol de Cliente
            'usuario'            => $this->request->getPost('usuario'),
            'nombre_completo'    => $this->request->getPost('nombre_completo'),
            'correo_electronico' => $this->request->getPost('correo_electronico'),
            'telefono'           => $this->request->getPost('telefono'),
            'contrasena_hash'    => $this->request->getPost('contrasena'), // Se guarda en texto plano por la DB actual
            'fecha_creacion'     => date('Y-m-d H:i:s')
        ];

        $usuarioModel->insert($data);

        // Mensaje de éxito y redirección
        session()->setFlashdata('success', '¡Cuenta creada exitosamente! Ahora puedes iniciar sesión.');
        return redirect()->to(site_url('login'));
    }

    public function logout()
    {
        // Destruimos la sesión
        session()->destroy();
        return redirect()->to(site_url('/'));
    }
}
