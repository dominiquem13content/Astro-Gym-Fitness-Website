/// <reference path="../.astro/types.d.ts" />

declare namespace App {
  interface Locals {
    admin?: import('./lib/auth').AdminUser;
  }
}
