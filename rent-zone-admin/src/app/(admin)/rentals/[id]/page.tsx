"use client";

import { use, useEffect, useState } from "react";
import Link from "next/link";
import { ArrowLeft, Calendar, Tag, CheckCircle, XCircle } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatDate, getInitials, rentalStatusColors } from "@/lib/utils";

export default function RentalDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [rental, setRental] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const fetchRental = async () => {
    try {
      const res = await adminService.rentals.get(id);
      setRental(res);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRental();
  }, [id]);

  const handleStatusChange = async (status: string) => {
    try {
      await adminService.rentals.updateStatus(id, status);
      fetchRental();
    } catch (err) {
      console.error(err);
    }
  };

  if (loading) {
    return <div className="flex justify-center py-20"><div className="w-8 h-8 border-4 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>;
  }

  if (!rental) {
    return <div className="py-20 text-center text-gray-500">Rental not found</div>;
  }

  return (
    <div className="space-y-5 max-w-[1000px]">
      <Link href="/rentals" className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-purple-600 transition-colors">
        <ArrowLeft size={15} /> Back to Rentals
      </Link>

      <div className="admin-card p-6">
        <div className="flex justify-between items-start">
          <div>
            <h2 className="text-xl font-bold text-gray-900">Rental #{rental.id.slice(-6)}</h2>
            <p className="text-sm text-gray-500 mt-1">Requested on {formatDate(rental.createdAt)}</p>
          </div>
          <span className={`badge ${rentalStatusColors[rental.status]}`}>{rental.status}</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-4 border-b pb-2">Product Details</h3>
            <div className="flex gap-4">
              <div className="w-20 h-20 rounded-lg bg-gray-100 overflow-hidden">
                {rental.product.imageURLs?.[0] ? (
                  <img src={rental.product.imageURLs[0]} alt="" className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-2xl">👗</div>
                )}
              </div>
              <div>
                <Link href={`/products/${rental.product.id}`} className="font-semibold text-purple-600 hover:underline">
                  {rental.product.name}
                </Link>
                <div className="flex gap-4 mt-2 text-sm text-gray-600">
                  <div className="flex items-center gap-1"><Tag size={14} /> ₹{rental.product.rentPricePerDay}/day</div>
                  <div className="flex items-center gap-1"><Tag size={14} /> ₹{rental.product.securityDeposit} deposit</div>
                </div>
              </div>
            </div>
          </div>

          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-4 border-b pb-2">Rental Period & Price</h3>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-500">Dates:</span>
                <span className="font-medium text-gray-900">{formatDate(rental.startDate)} — {formatDate(rental.endDate)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Total Amount:</span>
                <span className="font-bold text-gray-900">₹{rental.totalPrice}</span>
              </div>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-4 border-b pb-2">Renter (Buyer)</h3>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold">
                {getInitials(rental.rentedBy.name)}
              </div>
              <div>
                <Link href={`/users/${rental.rentedBy.id}`} className="font-semibold text-gray-900 hover:text-purple-600">
                  {rental.rentedBy.name}
                </Link>
              </div>
            </div>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-4 border-b pb-2">Owner (Seller)</h3>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                {getInitials(rental.rentedFrom.name)}
              </div>
              <div>
                <Link href={`/users/${rental.rentedFrom.id}`} className="font-semibold text-gray-900 hover:text-purple-600">
                  {rental.rentedFrom.name}
                </Link>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 pt-6 border-t border-gray-100">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">Admin Actions</h3>
          <div className="flex gap-3">
            <button onClick={() => handleStatusChange('cancelled')} className="btn-secondary text-red-600 border-red-200 hover:bg-red-50">
              <XCircle size={16} /> Force Cancel
            </button>
            <button onClick={() => handleStatusChange('returned')} className="btn-secondary text-emerald-600 border-emerald-200 hover:bg-emerald-50">
              <CheckCircle size={16} /> Mark as Returned
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
