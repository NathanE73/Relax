package com.example.backend

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
@SerialName("Cat")
data class Cat(
    override val name: String,
    val meow: Boolean,
    val lives: Int
) : Pet(PetType.Cat)
