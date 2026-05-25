package com.example.backend

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Order(
    val id: Int,
    val orderStatus: OrderStatus
) {
    @Serializable
    enum class OrderStatus {
        @SerialName("placed")
        Placed,

        @SerialName("processing")
        Processing,

        @SerialName("shipped")
        Shipped,

        @SerialName("delivered")
        Delivered
    }
}
