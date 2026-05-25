package com.example.backend

import kotlinx.serialization.Serializable

@Serializable
data class Order(
    val id: Int,
    val orderStatus: OrderStatus
)
